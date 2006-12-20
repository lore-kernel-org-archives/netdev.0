From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] drivers/atm/fore200e.c: cleanups
Date: Tue, 19 Dec 2006 19:36:46 -0800 (PST)
Message-ID: <20061219.193646.122617749.davem@davemloft.net>
References: <20061219041258.GC6993@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49995
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964834AbWLTDgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 22:36:47 -0500
To: bunk@stusta.de
In-Reply-To: <20061219041258.GC6993@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 19 Dec 2006 05:12:58 +0100

> This patch contains the following transformations from custom functions 
> to standard kernel version:
> - fore200e_kmalloc() -> kzalloc()
> - fore200e_kfree() -> kfree()
> - fore200e_swap() -> cpu_to_be32()
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Looks good, applied, thanks Adrian.
