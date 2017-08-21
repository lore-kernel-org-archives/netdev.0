From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v2] mt7601u: check memory allocation failure
Date: Mon, 21 Aug 2017 15:25:15 -0700
Message-ID: <20170821152515.717a4681@cakuba.netronome.com>
References: <20170821220617.21513-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, matthias.bgg@gmail.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821220617.21513-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2017 00:06:17 +0200, Christophe JAILLET wrote:
> Check memory allocation failure and return -ENOMEM in such a case, as
> already done a few lines below.
> 
> As 'dev->tx_q' can be NULL, we also need to check for that in
> 'mt7601u_free_tx()', and return early.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Acked-by: Jakub Kicinski <kubakici@wp.pl>
