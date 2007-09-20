From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] ucc_geth: remove unnecessary asm/ocp.h include from ucc_geth_mii.c
Date: Thu, 20 Sep 2007 15:56:14 -0500
Message-ID: <46F2DE6E.3070205@freescale.com>
References: <11902158442710-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:47548 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbXITU4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 16:56:17 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l8KKuFCN007944
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 13:56:15 -0700 (MST)
Received: from [10.82.19.119] (ld0169-tx32.am.freescale.net [10.82.19.119])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l8KKuEbB020744
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 15:56:14 -0500 (CDT)
In-Reply-To: <11902158442710-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur Tabi wrote:
> ucc_geth_mii.c includes <asm/ocp.h>, but it never needed it.  With commit
> 2f6c9d961081dc7b109eb19166244bcb2a5dfc28, the asm-powerpc => asm-ppc link
> is removed, and so ucc_geth_mii.c can no longer include include/asm-ppc/ocp.h,
> so the compile fails.  This patch removes the #include line.

Never mind -- I see Kumar fixed this bug some time ago, but it only recently 
made it into a repo.

-- 
Timur Tabi
Linux Kernel Developer @ Freescale
