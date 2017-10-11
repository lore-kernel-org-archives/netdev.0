From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ftgmac100: Request clock and set speed
Date: Wed, 11 Oct 2017 12:08:51 -0700 (PDT)
Message-ID: <20171011.120851.1428660689178106234.davem@davemloft.net>
References: <20171010044925.21078-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, andrew@aj.id.au
To: joel@jms.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010044925.21078-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joel Stanley <joel@jms.id.au>
Date: Tue, 10 Oct 2017 15:19:25 +1030

> According to the ASPEED datasheet, gigabit speeds require a clock of
> 100MHz or higher. Other speeds require 25MHz or higher.
> 
> Signed-off-by: Joel Stanley <joel@jms.id.au>

Hey Joel, it seems that Benjamin would like you to guard this new
logic with whether we have an aspeed configuration or not.

Thank you.
