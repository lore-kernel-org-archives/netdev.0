From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/14] drivers/isdn: delete double assignment
Date: Wed, 27 Oct 2010 12:24:38 -0700 (PDT)
Message-ID: <20101027.122438.191405610.davem@davemloft.net>
References: <1288088743-3725-11-git-send-email-julia@diku.dk>
	<4CC6C1C0.8020005@bfs.de>
	<Pine.LNX.4.64.1010261419510.25281@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wharms@bfs.de, isdn@linux-pingi.de,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1010261419510.25281@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Tue, 26 Oct 2010 14:20:56 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> Delete successive assignments to the same location.  In the first case, the
> hscx array has two elements, so change the assignment to initialize the
> second one.  In the second case, the two assignments are simply identical.
> Furthermore, neither is necessary, because the effect of the assignment is
> only visible in the next line, in the assignment in the if test.  The patch
> inlines the right hand side value in the latter assignment and pulls that
> assignment out of the if test.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
