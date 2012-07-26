From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169, 3.5.0, does't work at all
Date: Thu, 26 Jul 2012 21:56:58 +0200
Message-ID: <20120726195658.GA14668@electric-eye.fr.zoreil.com>
References: <88f2e8e7f795239ec4bc759dcda61665@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42753 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142Ab2GZUKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 16:10:17 -0400
Content-Disposition: inline
In-Reply-To: <88f2e8e7f795239ec4bc759dcda61665@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <denys@visp.net.lb> :
> Just pushed new kernel to test cluster and got this:
[...]
> [    1.606212] r8169 0000:03:00.0: eth1: RTL8168b/8111b at
> 0xf8606000, 00:08:54:57:7a:33, XID 18000000 IRQ 44
> [    1.606366] r8169 0000:03:00.0: eth1: jumbo features [frames:
> 4080 bytes, tx checksumming: ko]
> ....
> [   20.406090]     input device check on
> [   20.406177]     Actions configured
> [   21.526836] r8169 0000:02:00.0: eth0: link up
> [   28.038386] ------------[ cut here ]------------
> [   28.038438] WARNING: at net/sched/sch_generic.c:255
> dev_watchdog+0xd6/0x12a()
> [   28.038489] Hardware name:
> [   28.038534] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed

Right at startup.

Which kernel did you previously use ?

This is exactly the primary device I use to access my test computer.

.config and .dmesg will be welcome as well.

-- 
Ueimor
