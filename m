From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_pick_tx: use get_xps_q if xps map
 is set
Date: Fri, 17 May 2013 15:03:17 -0700
Message-ID: <1368828197.3301.112.camel@edumazet-glaptop>
References: <1368780528-15209-1-git-send-email-govindarajulu90@gmail.com>
	 <1368797733.3301.84.camel@edumazet-glaptop> <51968A01.7070105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: govind <govindarajulu90@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51968A01.7070105@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-05-18 at 01:20 +0530, govind wrote:

> I see. In ixgbe_select_queue we use __netdev_pick_tx only if packet is not
> FCOE & FIP.
> 
> If you see
> bnx2x_select_queue in drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c, line 1832
> and mlx4_en_select_queue in drivers/net/ethernet/mellanox/mlx4/en_tx.c, line 547.
> we cannot have xps working with these drivers.
> 
> This needs to be fixed by replacing __skb_tx_hash with __netdev_pick_tx. Am i 
> correct?

Yes, this seems better.
