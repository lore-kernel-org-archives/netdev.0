From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in
 balance-alb mode
Date: Thu, 20 Jul 2017 15:35:04 -0700 (PDT)
Message-ID: <20170720.153504.1900186208210668931.davem@davemloft.net>
References: <17EC94B0A072C34B8DCF0D30AD16044A0296FEF5@BPXM09GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tatsu@ab.jp.nec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A0296FEF5@BPXM09GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
Date: Thu, 20 Jul 2017 05:20:40 +0000

> balance-alb mode used to have transmit dynamic load balancing feature
> enabled by default.  However, transmit dynamic load balancing no longer
> works in balance-alb after commit 8b426dc54cf4 ("bonding: remove
> hardcoded value").
> 
> Both balance-tlb and balance-alb use the function bond_do_alb_xmit() to
> send packets.  This function uses the parameter tlb_dynamic_lb.
> tlb_dynamic_lb used to have the default value of 1 for balance-alb, but
> now the value is set to 0 except in balance-tlb.
> 
> Re-enable transmit dyanmic load balancing by initializing tlb_dynamic_lb
> for balance-alb similar to balance-tlb.
> 
> Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>

Applied and queued up for -stable, thanks.

Andy, thanks for the Fixes: tag.
