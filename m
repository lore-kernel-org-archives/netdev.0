From: Miroslav Zubcic <mvz@nimium.com>
Subject: Re: [PATCH] Re: ethernet/b44: Bug in b44.c:v0.93 (Mar, 2004)
 ethernet driver in 2.6.6
Date: Sat, 15 May 2004 20:07:50 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <lzbrkp36rr.fsf@anthea.home.int>
References: <lzekpnlxwl.fsf@nimiumvax.nimium.local>
	<20040514130206.GA9583@ee.oulu.fi> <20040515120518.GA9480@ee.oulu.fi>
	<20040515121112.GA9579@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, pavel@ucw.cz, netdev@oss.sgi.com,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S261752AbUEOSJL@vger.kernel.org>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20040515121112.GA9579@ee.oulu.fi> (Pekka Pietikainen's message
 of "Sat, 15 May 2004 15:11:12 +0300")
List-Id: netdev.vger.kernel.org

Pekka Pietikainen <pp@ee.oulu.fi> writes:

> On Sat, May 15, 2004 at 03:05:19PM +0300, Pekka Pietikainen wrote:
>> +	/* Enable CRC32, set proper LED modes and power on MAC */
>> +	bw32(B44_MAC_CTRL, MAC_CTRL_CRC32_ENAB | MAC_CTRL_PHY_LEDCTRL);
> Erk, that comment should of course be "power on PHY". I hate acronyms...
>
> --- linux-2.6.5-1.358/drivers/net/b44.c.orig	2004-05-15 13:59:57.000000000 +0300
> +++ linux-2.6.5-1.358/drivers/net/b44.c	2004-05-15 14:59:39.794720368 +0300
> @@ -27,8 +27,8 @@

Pekka, thank you very much for your patch. It looks like things are
working now:

dmesg part:
b44.c:v0.95 (May 15, 2004)
...
eth0: Broadcom 4400 10/100BaseT Ethernet 00:08:02:e2:2d:ba
ip_tables: (C) 2000-2002 Netfilter core team
b44: eth0: Link is down.
b44: eth0: Link is up at 100 Mbps, full duplex.
b44: eth0: Flow control is off for TX and off for RX.

I have tried moving large packets, NFS, ping etc ... no problem
anymore, it works.

Thanks again!


-- 
		The Network is the Filesystem.
