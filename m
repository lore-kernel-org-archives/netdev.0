From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [ 57/72] genirq: Unmask oneshot irqs when thread was not woken
Date: Sun, 4 Mar 2012 15:53:07 -0600
Message-ID: <20120304215307.GA27157@burratino>
References: <20120228010511.GA8453@kroah.com>
 <20120228010434.412979550@linuxfoundation.org>
 <87hay4dqjr.fsf@turtle.gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Sven Joachim <svenjoac@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34871 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754880Ab2CDVxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 16:53:17 -0500
Content-Disposition: inline
In-Reply-To: <87hay4dqjr.fsf@turtle.gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sven Joachim wrote:

> The laptop is an Acer TravelMate 2490 with a Broadcom chip:
>
> ,----
> | 06:02.0 Network controller: Broadcom Corporation BCM4318 [AirForce One 54g] 802.11g Wireless LAN Controller (rev 02)
> | 	Subsystem: AMBIT Microsystem Corp. TravelMate 2410
> | 	Flags: bus master, fast devsel, latency 64, IRQ 10
> | 	Memory at d0002000 (32-bit, non-prefetchable) [size=8K]
> | 	Kernel driver in use: b43-pci-bridge
> `----

Odd.  Does it use that driver with both working and non-working
kernels?
