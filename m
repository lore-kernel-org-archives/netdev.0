From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ieee802154: constify ieee802154_ops structures
Date: Mon, 21 Nov 2016 16:13:02 -0500 (EST)
Message-ID: <20161121.161302.699676538738993647.davem@davemloft.net>
References: <1479760214-32624-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, michael.hennerich@analog.com,
        aar@pengutronix.de, stefan@osg.samsung.com,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479760214-32624-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Tue, 22 Nov 2016 02:00:14 +0530

> Declare the structure ieee802154_ops as const as it is only passed as an
> argument to the function  ieee802154_alloc_hw. This argument is of type
> const struct ieee802154_ops *, so ieee80254_ops structures having this
> property can be declared as const.
> Done using Coccinelle:
 ...
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
