From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: atm: nicstar: Use the correct function to
 free some resources
Date: Tue, 19 Jul 2016 11:31:02 -0700 (PDT)
Message-ID: <20160719.113102.423760723208563634.davem@davemloft.net>
References: <1468739004-3471-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468739004-3471-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sun, 17 Jul 2016 09:03:24 +0200

> In 'get_scq', 'dma_alloc_coherent' has been used to allocate some
> resources, so we need to free them using 'dma_free_coherent' instead
> of 'kfree'.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied.
