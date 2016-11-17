From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: stmmac: replace if (netif_msg_type) by their
 netif_xxx counterpart
Date: Thu, 17 Nov 2016 13:31:14 -0500 (EST)
Message-ID: <20161117.133114.1570650287863112660.davem@davemloft.net>
References: <1479323381-26639-1-git-send-email-clabbe.montjoie@gmail.com>
        <1479323381-26639-3-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479323381-26639-3-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Wed, 16 Nov 2016 20:09:41 +0100

> From: LABBE Corentin <clabbe.montjoie@gmail.com>
> 
> As sugested by Joe Perches, we could replace all
> if (netif_msg_type(priv)) dev_xxx(priv->devices, ...)
> by the simpler macro netif_xxx(priv, hw, priv->dev, ...)
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied to net-next.
