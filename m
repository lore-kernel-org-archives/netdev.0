From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix parameter to dwmac4_set_umac_addr()
Date: Thu, 09 Jun 2016 23:39:24 -0700 (PDT)
Message-ID: <20160609.233924.1271084543681412582.davem@davemloft.net>
References: <1465410077-25381-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073AbcFJGj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 02:39:26 -0400
In-Reply-To: <1465410077-25381-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Wed,  8 Jun 2016 19:21:17 +0100

> The dwmac4_set_umac_addr() takes a struct mac_device_info as
> the first parameter, but is being passed a ioaddr instead from
> dwmac4_set_filter(). Fix the warning/bug by changing the first
> parameter.
> 
> drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46: warning: incorrect type in argument 1 (different address spaces)
> drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46:    expected struct mac_device_info *hw
> drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46:    got void [noderef] <asn:2>*ioaddr
> 
> Note, only compile tested this as do not have any
> hardware with it in.
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Applied.
