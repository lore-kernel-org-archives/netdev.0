From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove function sk_reset_txq()
Date: Tue, 22 Oct 2013 02:18:05 -0400 (EDT)
Message-ID: <20131022.021805.1325709347250113490.davem@davemloft.net>
References: <20131022041124.GA14122@will>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gamerh2o@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131022041124.GA14122@will>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ZHAO Gang <gamerh2o@gmail.com>
Date: Tue, 22 Oct 2013 12:11:24 +0800

> What sk_reset_txq() does is just calls function sk_tx_queue_reset(),
> and sk_reset_txq() is used only in sock.h, by dst_negative_advice().
> Let dst_negative_advice() calls sk_tx_queue_reset() directly so we
> can remove unneeded sk_reset_txq().
> 
> Signed-off-by: ZHAO Gang <gamerh2o@gmail.com>

Still doesn't apply.

Email this patch to yourself, I bet the patch you receive won't
apply cleanly.  Likely your email client is corrupting the patch.

You've already eaten enough of my time as a maintainer submitting
a patch that won't even apply.  Absolutely do not resubmit this
patch until you can email the patch successfully to yourself
and successfuly apply the patch you receive in that email to
the current net-next tree.
