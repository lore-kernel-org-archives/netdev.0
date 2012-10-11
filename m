From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 13:47:35 +0200
Message-ID: <1349956055.1232.9.camel@sakura.staff.proxad.net>
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
	 <1349952970.1232.5.camel@sakura.staff.proxad.net>
	 <1349954899.21172.8728.camel@edumazet-glaptop>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	Jon Masters <jonathan@jonmasters.org>,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:46523 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754578Ab2JKLrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2012 07:47:37 -0400
In-Reply-To: <1349954899.21172.8728.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2012-10-11 at 13:28 +0200, Eric Dumazet wrote:

> You probably are aware that a driver can use : 
> 
> - a fragment to hold the frame given by the hardware, with whatever
> alignment is needed by the hardware.
> 
> Then allocate an skb with enough room (128 bytes) to pull the headers as
> needed later.
> 
> skb = netdev_alloc_skb_ip_align(dev, 128);

What happen at tx time, supposing that same hardware cannot do SG ?

Aren't we going to memcpy the data into the head ?

-- 
Maxime
