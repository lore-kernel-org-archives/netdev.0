From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 12:56:10 +0200
Message-ID: <1349952970.1232.5.camel@sakura.staff.proxad.net>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <506ED18C.3010009@gmail.com> <20121005140556.GQ4625@n2100.arm.linux.org.uk>
	 <506EEFBB.3060705@gmail.com> <507619FA.6080001@jonmasters.org>
	 <yw1xtxu1pwtv.fsf@unicorn.mansr.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
	 <yw1xpq4ppcju.fsf@unicorn.mansr.com>
	 <1349949638.21172.8445.camel@edumazet-glaptop>
	 <1349950926.21172.8521.camel@edumazet-glaptop>
	 <20121011103257.GO4625@n2100.arm.linux.org.uk>
	 <1349952574.21172.8604.camel@edumazet-glaptop>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	=?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:45250 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754536Ab2JKK4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2012 06:56:12 -0400
In-Reply-To: <1349952574.21172.8604.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2012-10-11 at 12:49 +0200, Eric Dumazet wrote:


> So if you have an alignment fault, thats because IP header is not
> aligned on 4 bytes ?
> 
> If so a driver is buggy and must be fixed.

So a driver that does not align the ip header is buggy ?

I always thought it was ok not to do so (with a potential performance
penalty).

I have some MIPS hardware that is not able to DMA on anything but 32bits
aligned addresses (bcm63xx). I tried once to add a memcpy instead of
taking unaligned faults and the result was *much slower* on a ipv4
forwarding test (which is what the hardware is used for).

-- 
Maxime
