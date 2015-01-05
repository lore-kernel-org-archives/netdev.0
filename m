From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 crash also in 3.16.7
Date: Tue, 6 Jan 2015 00:00:14 +0100
Message-ID: <20150105230014.GA7802@electric-eye.fr.zoreil.com>
References: <20150105112044.GA5659@shelf.conquest>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ael <lawrence_a_e@ntlworld.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38092 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbbAEXAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 18:00:16 -0500
Content-Disposition: inline
In-Reply-To: <20150105112044.GA5659@shelf.conquest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ael <lawrence_a_e@ntlworld.com> :
[...]
> Jan  4 22:09:16 shelf kernel: [10650.233180] WARNING: CPU: 0 PID: 0 at /build/linux-CMiYW9/linux-3.16.7-ckt2/net/sched/sch_generic.c:264 dev_watchdog+0x236/0x240()
[...]
> Jan  4 22:09:16 shelf kernel: [10650.233263] Hardware name: Notebook                         W54_55SU1,SUW/W54_55SU1,SUW, BIOS 4.6.5 05/29/2014

The current kernel contains several changes for your (RTL_GIGA_MAC_VER_44)
8411 r8169 chipset that 3.16.7 doesn't know of. You should give it a try.

-- 
Ueimor
