From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: zatm: Fix an error handling path in
 'zatm_init_one()'
Date: Tue, 18 Jul 2017 11:38:18 -0700 (PDT)
Message-ID: <20170718.113818.1199145447611241421.davem@davemloft.net>
References: <20170717174241.18935-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717174241.18935-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Mon, 17 Jul 2017 19:42:41 +0200

> If 'dma_set_mask_and_coherent()' fails, we must undo the previous
> 'pci_request_regions()' call.
> Adjust corresponding 'goto' to jump at the right place of the error
> handling path.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied, thank you.
