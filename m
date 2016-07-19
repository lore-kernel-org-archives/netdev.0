From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ti: cpmac: Use the correct function to free some
 resources.
Date: Tue, 19 Jul 2016 11:30:57 -0700 (PDT)
Message-ID: <20160719.113057.1409751888061051013.davem@davemloft.net>
References: <1468736150-30111-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468736150-30111-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sun, 17 Jul 2016 08:15:50 +0200

> In 'cpmac_open', 'dma_alloc_coherent' has been used to allocate some
> resources, so we need to free them using 'dma_free_coherent' instead
> of 'kfree'.
> 
> Also, we don't need to free these resources if the allocation has failed.
> So I have slighly modified the goto label in this case.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied.
