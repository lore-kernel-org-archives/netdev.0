From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7] net: stmmac: Delete dead code for MDIO
 registration
Date: Tue, 05 Sep 2017 14:36:48 -0700 (PDT)
Message-ID: <20170905.143648.1047204407667149649.davem@davemloft.net>
References: <20170904084136.21490-1-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: romain.perier@collabora.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170904084136.21490-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Romain Perier <romain.perier@collabora.com>
Date: Mon,  4 Sep 2017 10:41:36 +0200

> This code is no longer used, the logging function was changed by commit
> fbca164776e4 ("net: stmmac: Use the right logging function in stmmac_mdio_register").
> It was previously showing information about the type of the IRQ, if it's
> polled, ignored or a normal interrupt. As we don't want information loss,
> I have moved this code to phy_attached_print().
> 
> Fixes: fbca164776e4 ("net: stmmac: Use the right logging function in stmmac_mdio_register")
> Signed-off-by: Romain Perier <romain.perier@collabora.com>

Applied.
