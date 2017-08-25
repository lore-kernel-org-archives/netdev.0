From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tg3: Be drop monitor friendly
Date: Thu, 24 Aug 2017 18:28:03 -0700 (PDT)
Message-ID: <20170824.182803.373650560554315773.davem@davemloft.net>
References: <20170825004711.19793-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com,
        siva.kallam@broadcom.com, prashant@broadcom.com,
        mchan@broadcom.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825004711.19793-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 24 Aug 2017 17:47:11 -0700

> tg3_tx() does the normal packet TX completion,
> tigon3_dma_hwbug_workaround() and tg3_tso_bug() both need to allocate a
> new SKB that is suitable to workaround HW bugs, and finally
> tg3_free_rings() is doing ring cleanup. Use dev_consume_skb_any() for
> these 3 locations to be SKB drop monitor friendly.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
