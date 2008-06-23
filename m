From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] e1000,e1000e,igb: make ioport free for adapters that
 need NO ioport resources
Date: Mon, 23 Jun 2008 17:28:21 +0900
Message-ID: <485F5EA5.9050503@jp.fujitsu.com>
References: <485B1B8E.1060108@jp.fujitsu.com> <485D4630.1090007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:35613 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbYFWI3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 04:29:14 -0400
In-Reply-To: <485D4630.1090007@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Auke

>> * [PATCH 1/3] e1000: make ioport free
>> * [PATCH 2/3] e1000e: make ioport free
>> * [PATCH 3/3] igb: make ioport free
> 
> I think patch 2 and 3 are way too large since igb and e1000e can be totally ioport
> free at all times. There is no need to keep compatibility code for ioport in those
> drivers as it's unlikely that this will ever be needed.

I left an old implementation in case adapters that need ioport resources appear,
but it's true that these codes are a little redundant for igb and e1000e drivers.

> So, perhaps you can remove the ioport code from those 2 drivers (e1000e/igb)
> completely and resubmit to Jeff Kirsher?

  OK, I'll send them later.

Best regards,
Taku Izumi <izumi.taku@jp.fujitsu.com>

