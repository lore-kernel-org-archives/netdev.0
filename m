From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: sky2 hang with 2.6.28 and 2.6.29-rc2
Date: Thu, 22 Jan 2009 22:04:29 -0000 (WET)
Message-ID: <1246.87.196.10.75.1232661869.squirrel@webmail.decimal.pt>
References: <3876.87.196.10.75.1232658152.squirrel@webmail.decimal.pt>
    <20090123083842.253f68c4@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly05.isp.novis.pt ([195.23.133.214]:36449 "EHLO
	mailrly05.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758343AbZAVWDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:03:02 -0500
In-Reply-To: <20090123083842.253f68c4@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see Stephen,
Well, no problem then since the driver don't crash.
with 2.6.27 it used to crash.
I'll stay tunned to see it with 2.6.28+ the crash will happen, and if yes,
how do i get the dump?
That info doesn't get logged in the logs don't know why (maybe some
dumbness from me)

> On Thu, 22 Jan 2009 21:02:32 -0000 (WET)
> "Jorge Bastos" <mysql.jorge@decimal.pt> wrote:
>
>> Hi,
>> I've noticed with the kernel's (two different machines) 2.6.28 and
>> 2.6.29-rc2, that the NIC's were hanging.
>>
>> In the kernel output i have:
>> ---
>> sky2 eth0: receiver hang detected
>> sky2 eth0: disabling interface
>> sky2 eth0: enabling interface
>> sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control rx
>> ---
>
> Marvell ram fifo has hardware problem where if it gets full it hangs.
> The driver snoops to look for this, and the should recover. Unfortunately,
> the recovery may take long enough to disturb connections.
>


