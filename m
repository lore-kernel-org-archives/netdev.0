From: David Miller <davem@davemloft.net>
Subject: Re: drivers: net: cpsw: Fix broken loop condition in switch mode
Date: Fri, 31 Oct 2014 16:17:12 -0400 (EDT)
Message-ID: <20141031.161712.591711555593004517.davem@davemloft.net>
References: <20141031172854.GJ24110@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hs@denx.de, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141031172854.GJ24110@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Date: Fri, 31 Oct 2014 13:28:54 -0400

> 0d961b3b52f566f823070ce2366511a7f64b928c (drivers: net: cpsw: fix buggy
> loop condition) accidentally fixed a loop comparison in too many places
> while fixing a real bug.
> 
> It was correct to fix the dual_emac mode section since there 'i' is used
> as an index into priv->slaves which is a 0 based array.
> 
> However the other two changes (which are only used in switch mode)
> are wrong since there 'i' is actually the ALE port number, and port 0
> is the host port, while port 1 and up are the slave ports.
> 
> Putting the loop condition back in the switch mode section fixes it.
> 
> A comment has been added to point out the intent clearly to avoid future
> confusion.  Also a comment is fixed that said the opposite of what was
> actually happening.
> 
> Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>
> Acked-by: Heiko Schocher <hs@denx.de>

Applied.
