From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 v2] drivers/net/ethernet/ti: Move call to PTR_ERR
 after reassignment
Date: Thu, 02 Feb 2012 14:37:49 -0500 (EST)
Message-ID: <20120202.143749.209790216360616297.davem@davemloft.net>
References: <1328194382-32465-1-git-send-email-Julia.Lawall@lip6.fr>
	<1328194382-32465-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328194382-32465-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Thu,  2 Feb 2012 15:53:01 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> PTR_ERR should be called before its argument is cleared.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> Reported-by: Josh Triplett <josh@joshtriplett.org>

Applied, thanks.
