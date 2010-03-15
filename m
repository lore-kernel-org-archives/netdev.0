From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] drivers/net: drop redundant memset
Date: Mon, 15 Mar 2010 15:47:14 -0700 (PDT)
Message-ID: <20100315.154714.23695928.davem@davemloft.net>
References: <Pine.LNX.4.64.1003092213500.4974@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	anil.murthy@neterion.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1003092213500.4974@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Tue, 9 Mar 2010 22:14:11 +0100 (CET)

> From: Julia Lawall <julia@diku.dk>
> 
> The region set by the call to memset is immediately overwritten by the
> subsequent call to memcpy.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression e1,e2,e3,e4;
> @@
> 
> - memset(e1,e2,e3);
>   memcpy(e1,e4,e3);
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks!
