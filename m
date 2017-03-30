From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmmac: dwmac-rk: Add handling for
 RGMII_ID/RXID/TXID
Date: Thu, 30 Mar 2017 10:52:55 -0700 (PDT)
Message-ID: <20170330.105255.378847215679122760.davem@davemloft.net>
References: <1490789539-43920-1-git-send-email-w.egorov@phytec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-rockchip@lists.infradead.org
To: w.egorov@phytec.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490789539-43920-1-git-send-email-w.egorov@phytec.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wadim Egorov <w.egorov@phytec.de>
Date: Wed, 29 Mar 2017 14:12:19 +0200

> ATM dwmac-rk will always set and enable it's internal delay lines.
> Using PHY internal delays in combination with the phy-mode
> rgmii-id/rxid/txid was not possible. Only rgmii was supported.
> 
> Now we can disable rockchip's gmac delay lines and also use
> rgmii-id/rxid/txid.
> 
> Tested only with a RK3288 based board.
> 
> Signed-off-by: Wadim Egorov <w.egorov@phytec.de>
> ---
> Changes in v2: Added parenthesis around both expressions in DELAY_ENABLE

Applied to net-next, thanks.
