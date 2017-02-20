From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: Fix a memory leak in error handling path
Date: Mon, 20 Feb 2017 10:34:05 -0500 (EST)
Message-ID: <20170220.103405.914863932599172326.davem@davemloft.net>
References: <20170219093505.8620-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170219093505.8620-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sun, 19 Feb 2017 10:35:05 +0100

> If 'dma_alloc_coherent()' fails, we should release resources allocated so
> far, just as done in all other cases in this function.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied.
