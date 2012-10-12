From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 delay / segfault
Date: Fri, 12 Oct 2012 23:05:03 +0200
Message-ID: <20121012210503.GA2054@electric-eye.fr.zoreil.com>
References: <50787109.7080605@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
To: Roland Stigge <stigge@antcom.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54592 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab2JLVZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 17:25:23 -0400
Content-Disposition: inline
In-Reply-To: <50787109.7080605@antcom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Stigge <stigge@antcom.de> :
[...]
> on a Samsung laptop (x86_64, kernel 3.6.0), I get the following messages in the kernel
> log after a suspend/resume cycle (doesn't happen after every suspend/resume but sometimes):
> 
> Oct 12 21:02:27 darwin kernel: [ 4289.829755] r8169 0000:02:00.0: wake-up capability disabled by ACPI
> Oct 12 21:02:27 darwin kernel: [ 4289.830351] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
[...]
> Oct 12 21:02:27 darwin kernel: [ 4289.858920] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
[...]
> Oct 12 21:04:56 darwin kernel: [ 4441.330385] r8169 0000:02:00.0: eth0: rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
> Oct 12 21:04:56 darwin kernel: [ 4441.331592] r8169 0000:02:00.0: eth0: rtl_csiar_cond == 1 (loop: 100, delay: 10).
> Oct 12 21:04:56 darwin kernel: [ 4441.332727] r8169 0000:02:00.0: eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[...]
> Oct 12 21:04:56 darwin kernel: [ 4441.343912] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).

The device seems completely unresponsive :o/

> Oct 12 21:04:56 darwin kernel: [ 4441.454689] r8169 0000:02:00.0: eth0: link up
> 
> I copied a bigger part of the kernel log at http://antcom.de/kernel/dmesg.
> 
> Please tell me how I can help debugging or what else information you need.

The device does not recover despite the "link up" message, right ?

Can you send the XID line from the r8169 driver ? It should be in the
upper part of the dmesg log.

Which kernel version did you previously use ?

-- 
Ueimor
