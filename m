From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [NET-NEXT PATCH 08/14] e1000e: link up/down messages must follow a specific format
Date: Fri, 21 Nov 2008 11:23:42 -0800
Message-ID: <9929d2390811211123i284a3939lf96e53208ee8357e@mail.gmail.com>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	 <20081121190110.32313.43591.stgit@gitlost.lost>
	 <1227294295.23438.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Bruce Allan" <bruce.w.allan@intel.com>
To: "Dan Williams" <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f11.google.com ([209.85.217.11]:65482 "EHLO
	mail-gx0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbYKUT1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:27:06 -0500
Received: by gxk4 with SMTP id 4so964189gxk.13
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 11:27:03 -0800 (PST)
In-Reply-To: <1227294295.23438.17.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 11:04 AM, Dan Williams <dcbw@redhat.com> wrote:
> On Fri, 2008-11-21 at 11:01 -0800, Jeff Kirsher wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> The system log messages created on a link status change need to follow a
>> specific format to work with tools some customers use.
>
> Um, shouldn't those tools be listening to netlink for carrier events, or
> are these tools run on a separate machine using on some later date using
> the logs from the machine with the e1000e?
>
> Dan
>

>From my understanding these tools are looking at the logs and that is
why we need to have a consistent log message.

-- 
Cheers,
Jeff
