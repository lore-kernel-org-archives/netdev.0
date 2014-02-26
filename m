From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fw: [Bug 71191] New: WARNING: CPU: 0 PID: 0 at
 net/sched/sch_generic.c:264 dev_watchdog+0x266/0x270()
Date: Thu, 27 Feb 2014 00:37:00 +0100
Message-ID: <20140226233700.GA3452@electric-eye.fr.zoreil.com>
References: <20140226130223.49af845b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58018 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbaBZXhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 18:37:04 -0500
Content-Disposition: inline
In-Reply-To: <20140226130223.49af845b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> :
[...]
> [ 3909.248340] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H,
> BIOS F9 01/20/2014

https://bugzilla.kernel.org/buglist.cgi?quicksearch=Z87M

Scary.

> [ 3909.248358]  [<ffffffff815a4a96>] dev_watchdog+0x266/0x270
[...]
> [ 3909.248403]  [<ffffffff81d2271e>] x86_64_start_kernel+0x13e/0x14d
> [ 3909.248404] ---[ end trace ec86fade884a2d17 ]---
> [ 3909.322070] r8169 0000:02:00.0 p4p1: rtl_txcfg_empty_cond == 0 (loop: 666,
> delay: 100).
> [ 3909.324191] r8169 0000:02:00.0 p4p1: link up
> [ 3963.292670] r8169 0000:02:00.0 p4p1: rtl_txcfg_empty_cond == 0 (loop: 666,
> delay: 100).
> [ 3963.294785] r8169 0000:02:00.0 p4p1: link up
> [ 3986.303736] r8169 0000:02:00.0 p4p1: link down
> [ 4017.856241] r8169 0000:02:00.0 p4p1: link up

I'll take a look.

Thanks.

-- 
Ueimor
