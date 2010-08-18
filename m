From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/16] drivers/net/qlcnic: Use available error codes
Date: Wed, 18 Aug 2010 14:28:42 -0700 (PDT)
Message-ID: <20100818.142842.28795157.davem@davemloft.net>
References: <Pine.LNX.4.64.1008161828520.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, anirban.chakraborty@qlogic.com,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1008161828520.19313@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Mon, 16 Aug 2010 18:29:13 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> The error code is stored in the variable err, but it is the variable ret
> that is returned instead.  So store the error code in ret.  Err is then
> useless.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
