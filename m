From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: mv643xx_eth: Be drop monitor friendly
Date: Thu, 24 Aug 2017 21:29:46 -0700 (PDT)
Message-ID: <20170824.212946.1539831765103537454.davem@davemloft.net>
References: <20170825035540.26713-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825035540.26713-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 24 Aug 2017 20:55:40 -0700

> txq_reclaim() does the normal transmit queue reclamation and
> rxq_deinit() does the RX ring cleanup, none of these are packet drops,
> so use dev_consume_skb() for both locations.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
