From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/3] e1000,e1000e,igb: make ioport free for adapters that need NO ioport resources
Date: Mon, 23 Jun 2008 16:40:56 -0700
Message-ID: <9929d2390806231640l7fc89221j6ff879d1e5005771@mail.gmail.com>
References: <485B1B8E.1060108@jp.fujitsu.com> <485D4630.1090007@intel.com>
	 <485F5EA5.9050503@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Tomohiro Kusumi" <kusumi.tomohiro@jp.fujitsu.com>
To: "Taku Izumi" <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:52846 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbYFWXk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 19:40:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so7335099rvb.1
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 16:40:56 -0700 (PDT)
In-Reply-To: <485F5EA5.9050503@jp.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008 at 1:28 AM, Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:
> Dear Auke
>
>>> * [PATCH 1/3] e1000: make ioport free
>>> * [PATCH 2/3] e1000e: make ioport free
>>> * [PATCH 3/3] igb: make ioport free
>>
>> I think patch 2 and 3 are way too large since igb and e1000e can be
>> totally ioport
>> free at all times. There is no need to keep compatibility code for ioport
>> in those
>> drivers as it's unlikely that this will ever be needed.
>
> I left an old implementation in case adapters that need ioport resources
> appear,
> but it's true that these codes are a little redundant for igb and e1000e
> drivers.
>
>> So, perhaps you can remove the ioport code from those 2 drivers
>> (e1000e/igb)
>> completely and resubmit to Jeff Kirsher?
>
>  OK, I'll send them later.
>

The updated patchset looks fine.  ACK.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
