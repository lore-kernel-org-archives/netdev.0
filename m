From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] drivers/atm/idt77252.c: Remove unnecessary error
 check
Date: Sun, 03 Oct 2010 22:06:25 -0700 (PDT)
Message-ID: <20101003.220625.260083752.davem@davemloft.net>
References: <1286027958-7333-4-git-send-email-julia@diku.dk>
	<4CA73D26.7090109@bfs.de>
	<Pine.LNX.4.64.1010021636330.21879@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wharms@bfs.de, chas@cmf.nrl.navy.mil,
	kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1010021636330.21879@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 2 Oct 2010 16:37:07 +0200 (CEST)

> This code does not call deinit_card(card); in an error case, as done in
> other error-handling code in the same function.  But actually, the called
> function init_sram can only return 0, so there is no need for the error
> check at all.
> 
> init_sram is also given a void return type, and its single return statement
> at the end of the function is dropped.
> 
> A simplified version of the sematic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thank you.
