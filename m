From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] stmmac: platform: Move plat_dat checking earlier
Date: Sat, 29 Nov 2014 21:12:25 -0800 (PST)
Message-ID: <20141129.211225.2031104016189256005.davem@davemloft.net>
References: <1417093534-21884-1-git-send-email-chenhc@lemote.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, vbridgers2013@gmail.com,
	netdev@vger.kernel.org
To: chenhc@lemote.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbaK3FIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 00:08:14 -0500
In-Reply-To: <1417093534-21884-1-git-send-email-chenhc@lemote.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huacai Chen <chenhc@lemote.com>
Date: Thu, 27 Nov 2014 21:05:34 +0800

> Original code only check/alloc plat_dat for the CONFIG_OF case, this
> patch check/alloc it earlier and unconditionally to avoid kernel build
> warnings:
> 
> drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:275
> stmmac_pltfr_probe() warn: variable dereferenced before check 'plat_dat'
> 
> V2: Fix coding style.
> 
> Signed-off-by: Huacai Chen <chenhc@lemote.com>

Applied, thanks.
