From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: stmmac: unify mdio functions
Date: Sat, 03 Dec 2016 15:24:18 -0500 (EST)
Message-ID: <20161203.152418.772961535189895221.davem@davemloft.net>
References: <1480605581-13350-1-git-send-email-clabbe.montjoie@gmail.com>
        <1480605581-13350-2-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480605581-13350-2-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Thu,  1 Dec 2016 16:19:41 +0100

> stmmac_mdio_{read|write} and stmmac_mdio_{read|write}_gmac4 are not
> enought different for being split.
> The only differences between thoses two functions are shift/mask for
> addr/reg/clk_csr.
> 
> This patch introduce a per platform set of variable for setting thoses
> shift/mask and unify mdio read and write functions.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied.
