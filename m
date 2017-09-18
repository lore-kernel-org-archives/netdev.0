From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/ethernet/freescale: fix warning for ucc_geth
Date: Mon, 18 Sep 2017 14:56:47 -0700 (PDT)
Message-ID: <20170918.145647.945477632021094854.davem@davemloft.net>
References: <20170915055847.29716-1-valentin.longchamp@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, netdev@vger.kernel.org,
        christophe.leroy@c-s.fr, linuxppc-dev@lists.ozlabs.org
To: valentin.longchamp@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbdIRV4u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:56:50 -0400
In-Reply-To: <20170915055847.29716-1-valentin.longchamp@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentin Longchamp <valentin.longchamp@keymile.com>
Date: Fri, 15 Sep 2017 07:58:47 +0200

> uf_info.regs is resource_size_t i.e. phys_addr_t that can be either u32
> or u64 according to CONFIG_PHYS_ADDR_T_64BIT.
> 
> The printk format is thus adaptet to u64 and the regs value cast to u64
> to take both u32 and u64 into account.
> 
> Signed-off-by: Valentin Longchamp <valentin.longchamp@keymile.com>

Applied to net-next, thanks.
