From: Andi Kleen <andi@firstfloor.org>
Subject: __bad_udelay in network driver breaks build
Date: Mon, 18 Oct 2010 13:52:30 +0200
Message-ID: <20101018115230.GA27565@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54051 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab0JRLwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 07:52:38 -0400
Received: from basil.firstfloor.org (p5B3C94F2.dip0.t-ipconnect.de [91.60.148.242])
	by one.firstfloor.org (Postfix) with ESMTP id 11A951A9804F
	for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 13:52:31 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Current Linus master x86-64 allyesconfig fails with

drivers/built-in.o: In function `tms380tr_chipset_init':
tms380tr.c:(.text+0x10f02de): undefined reference to `__bad_udelay'
tms380tr.c:(.text+0x10f03ab): undefined reference to `__bad_udelay'
tms380tr.c:(.text+0x10f0400): undefined reference to `__bad_udelay'
tms380tr.c:(.text+0x10f07b2): undefined reference to `__bad_udelay'
tms380tr.c:(.text+0x10f08ed): undefined reference to `__bad_udelay'
make[2]: *** [.tmp_vmlinux1] Error 1

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
