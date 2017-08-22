From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/hsr: Check skb_put_padto() return value
Date: Tue, 22 Aug 2017 13:49:43 -0700 (PDT)
Message-ID: <20170822.134943.186346483000054388.davem@davemloft.net>
References: <20170821195910.28752-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mail@pheise.de, peter.heise@airbus.com,
        arvid.brodin@alten.se, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821195910.28752-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 21 Aug 2017 12:59:10 -0700

> skb_put_padto() will free the sk_buff passed as reference in case of
> errors, but we still need to check its return value and decide what to
> do.
> 
> Detected by CoverityScan, CID#1416688 ("CHECKED_RETURN")
> 
> Fixes: ee1c27977284 ("net/hsr: Added support for HSR v1")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
