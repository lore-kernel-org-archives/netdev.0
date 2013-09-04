From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] drivers:net: delete premature free_irq
Date: Wed, 04 Sep 2013 13:18:37 -0400 (EDT)
Message-ID: <20130904.131837.936191711263259013.davem@davemloft.net>
References: <1378115661-5371-1-git-send-email-Julia.Lawall@lip6.fr>
	<1378115661-5371-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcuos.com@gmail.com, kernel-janitors@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378115661-5371-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon,  2 Sep 2013 11:54:21 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Free_irq is not needed if there has been no request_irq.  Free_irq is
> removed from both the probe and remove functions.  The correct request_irq
> and free_irq are found in the open and close functions.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thank you.
