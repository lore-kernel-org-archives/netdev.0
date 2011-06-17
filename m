From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Use pr_<level>, netdev_<level> and
 netif_<level>
Date: Thu, 16 Jun 2011 23:35:42 -0400 (EDT)
Message-ID: <20110616.233542.1974667912524600949.davem@davemloft.net>
References: <1f8bdbed8f110b214daaff8350ae9bde68c9cc12.1308076047.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, sebastian.belden@googlemail.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1f8bdbed8f110b214daaff8350ae9bde68c9cc12.1308076047.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 14 Jun 2011 11:57:47 -0700

> Use the current logging styles.
> 
> Add #define DEBUG to get same output for <foo>_dbg messages.
> Convert a few bare printks to pr_err.
> 
> Fix a likely copy/paste defect where a test was done with RX values:
>         if (num_rx_qs > MAX_RX_QS) {
> but TX limits were emitted:
>         printk(KERN_ERR "num_rx_qs(=%d) greater than MAX_RX_QS(=%d)\n",
>                               num_tx_qs, MAX_TX_QS);
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
