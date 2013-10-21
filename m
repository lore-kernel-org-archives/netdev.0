From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: remove function sk_reset_txq()
Date: Mon, 21 Oct 2013 17:18:29 -0400 (EDT)
Message-ID: <20131021.171829.2297768337604122109.davem@davemloft.net>
References: <20131020013757.GA25265@will>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gamerh2o@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131020013757.GA25265@will>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ZHAO Gang <gamerh2o@gmail.com>
Date: Sun, 20 Oct 2013 09:37:57 +0800

> What sk_reset_txq() does is just calls function sk_tx_queue_reset(),
> and sk_reset_txq() is used only in sock.h, by dst_negative_advice().
> Let dst_negative_advice() calls sk_tx_queue_reset() directly so we
> can remove unneeded sk_reset_txq().
> 
> Signed-off-by: ZHAO Gang <gamerh2o@gmail.com>
> change a typo in patch description: sock.c -> sock.h

This patch does not apply cleanly to net-next, please fix this up
and resubmit.

Thanks.
