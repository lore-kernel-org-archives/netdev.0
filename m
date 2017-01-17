From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: add missing of_node_put
Date: Tue, 17 Jan 2017 14:10:54 -0500 (EST)
Message-ID: <20170117.141054.244353366907267226.davem@davemloft.net>
References: <1484652201-20048-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, kernel-janitors@vger.kernel.org,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1484652201-20048-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 17 Jan 2017 12:23:21 +0100

> The function stmmac_dt_phy provides several possibilities for initializing
> plat->mdio_node, all of which have the effect of increasing the reference
> count of the assigned value.  This field is not updated elsewhere, so the
> value is live until the end of the lifetime of plat (devm_allocated), just
> after the end of stmmac_remove_config_dt.  Thus, add an of_node_put on
> plat->mdio_node in stmmac_remove_config_dt.  It is possible that the field
> mdio_node is never initialized, but of_node_put is NULL-safe, so it is also
> safe to call of_node_put in that case.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks Julia.
