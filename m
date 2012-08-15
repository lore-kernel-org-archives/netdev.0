From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] drivers/net/ethernet/ti/davinci_cpdma.c: Remove
 potential NULL dereference
Date: Tue, 14 Aug 2012 17:00:10 -0700 (PDT)
Message-ID: <20120814.170010.1136116037664193225.davem@davemloft.net>
References: <1344959388-19719-1-git-send-email-Julia.Lawall@lip6.fr>
	<1344959388-19719-5-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344959388-19719-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 14 Aug 2012 17:49:47 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> If the NULL test is necessary, the initialization involving a dereference of
> the tested value should be moved after the NULL test.
> 
> The sematic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks.
