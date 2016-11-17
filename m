From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: netcp: replace IS_ERR_OR_NULL by IS_ERR
Date: Wed, 16 Nov 2016 23:27:07 -0500 (EST)
Message-ID: <20161116.232707.1586517242816228983.davem@davemloft.net>
References: <1479293014-18811-1-git-send-email-Julia.Lawall@lip6.fr>
        <1479293014-18811-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, kernel-janitors@vger.kernel.org,
        m-karicheri2@ti.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, christophe.jaillet@wanadoo.fr
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479293014-18811-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed, 16 Nov 2016 11:43:33 +0100

> knav_queue_open always returns an ERR_PTR value, never NULL.  This can be
> confirmed by unfolding the function calls and conforms to the function's
> documentation.  Thus, replace IS_ERR_OR_NULL by IS_ERR in error checks.
> 
> The change is made using the following semantic patch:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied to net-next, thanks.
