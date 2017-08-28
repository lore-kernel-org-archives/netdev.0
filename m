From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net: stmmac: sun8i: Remove the compatibles
Date: Mon, 28 Aug 2017 15:23:00 -0700 (PDT)
Message-ID: <20170828.152300.453206773958057088.davem@davemloft.net>
References: <20170825191217.10278-1-maxime.ripard@free-electrons.com>
        <20170825191217.10278-5-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arm@kernel.org, wens@csie.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        f.fainelli@gmail.com, clabbe.montjoie@gmail.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org
To: maxime.ripard@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825191217.10278-5-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Fri, 25 Aug 2017 21:12:17 +0200

> Since the bindings have been controversial, and we follow the DT stable ABI
> rule, we shouldn't let a driver with a DT binding that might change slip
> through in a stable release.
> 
> Remove the compatibles to make sure the driver will not probe and no-one
> will start using the binding currently implemented. This commit will
> obviously need to be reverted in due time.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Applied to net tree.
