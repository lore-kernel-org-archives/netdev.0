From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ftgmac100: Fix oops in probe on failure to find
 associated PHY
Date: Tue, 22 Aug 2017 14:20:14 -0700 (PDT)
Message-ID: <20170822.142014.1004582480730502532.davem@davemloft.net>
References: <20170822063622.21550-1-andrew@aj.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org, joel@jms.id.au,
        linux-kernel@vger.kernel.org, openbmc@lists.ozlabs.org,
        linux-aspeed@lists.ozlabs.org, ryan_chen@aspeedtech.com
To: andrew@aj.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170822063622.21550-1-andrew@aj.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Jeffery <andrew@aj.id.au>
Date: Tue, 22 Aug 2017 16:06:22 +0930

> netif_napi_del() should be paired with netif_napi_add(), however no
> such call takes place in ftgmac100_probe(). This triggers a NULL
> pointer dereference if e.g. no PHY is found by the MDIO probe:
 ...
> Signed-off-by: Andrew Jeffery <andrew@aj.id.au>

Applied, thanks.
