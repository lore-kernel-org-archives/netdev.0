From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] mt7601u: check memory allocation failure
Date: Thu, 24 Aug 2017 09:55:46 +0000 (UTC)
Message-ID: <20170824095546.9DE6C602B3@smtp.codeaurora.org>
References: <20170821220617.21513-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, kubakici@wp.pl, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mediatek@lists.infradead.org, matthias.bgg@gmail.com,
 Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
 linux-arm-kernel@lists.infradead.org
To: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170821220617.21513-1-christophe.jaillet@wanadoo.fr>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Christophe Jaillet <christophe.jaillet@wanadoo.fr> wrote:

> Check memory allocation failure and return -ENOMEM in such a case, as
> already done a few lines below.
> 
> As 'dev->tx_q' can be NULL, we also need to check for that in
> 'mt7601u_free_tx()', and return early.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> Acked-by: Jakub Kicinski <kubakici@wp.pl>

Patch applied to wireless-drivers-next.git, thanks.

b3b2f62c6238 mt7601u: check memory allocation failure

-- 
https://patchwork.kernel.org/patch/9913855/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
