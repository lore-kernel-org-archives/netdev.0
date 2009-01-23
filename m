From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: RE: 2.6.28: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed
 out
Date: Fri, 23 Jan 2009 08:06:40 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0901230802180.10635@p34.internal.lan>
References: <alpine.DEB.1.10.0901131617550.6193@p34.internal.lan> <20090114213618.a610d647.akpm@linux-foundation.org> <alpine.DEB.1.10.0901150407130.6755@p34.internal.lan> <20090115202104.GA32495@electric-eye.fr.zoreil.com>
 <006b01c97d43$204fc7b0$60ef5710$@net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'Andrew Morton' <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, 'Alan Piszcz' <ap@solarrain.com>,
	netdev@vger.kernel.org
To: Doug Bazarnic <kernel@bazarnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucidpixels.com ([75.144.35.66]:34909 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034AbZAWNGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2009 08:06:41 -0500
In-Reply-To: <006b01c97d43$204fc7b0$60ef5710$@net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 23 Jan 2009, Doug Bazarnic wrote:

> I've just setup a lab in the office to test out IPVS, and I'm using an Asus
> p5q-ws MB with dual r8169 nics on board.  This machine is acting as a load
> balancer, and it's just directing packets to the web servers.  Lots of
> requests...
>
> Justin Piszcz <jpiszcz@lucidpixels.com> :
> [...]
>> It is the first time I have ever seen it on this system, while running
>> 2.6.28.  I have never seen the error in the past (at least not that I can
>> remember/no log entries) for 2.6.27 or below.
>
> Does it translate into a temporary network hiccup, say a few seconds,
> or does it mean a final loss of networking ?
That is what it seemed like, enough to kill a DVD burn.

>
> Given the timestamp, the driver seemed to worked for some amount of time
> before breaking, did it not ? It would thus be different from the usual
> "no link at startup" problem.
Yes it did.

>
> Can you send a complete dmesg, including the r8169 XID line ?
# grep -i 8169 dmesg 
[    0.428875] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    0.428968] r8169 0000:05:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.429060] r8169 0000:05:00.0: setting latency timer to 64
[    0.429132] r8169 0000:05:00.0: irq 378 for MSI/MSI-X
[   20.267767] r8169: eth0: link up
[   20.267846] r8169: eth0: link up

http://home.comcast.net/~jpiszcz/20090123/dmesg.txt

Justin.

