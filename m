From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bcmgenet: Use BUG_ON instead of if condition
 followed by BUG
Date: Fri, 27 Oct 2017 23:56:07 +0900 (KST)
Message-ID: <20171027.235607.430416647630428682.davem@davemloft.net>
References: <20171026121601.GA6113@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026121601.GA6113@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 26 Oct 2017 07:16:01 -0500

> Use BUG_ON instead of if condition followed by BUG.
> 
> Something to notice in this particular case is that unlikely()
> is already being called inside BUG_ON macro.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
