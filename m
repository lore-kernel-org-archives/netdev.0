From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] netfilter: bridge: fix wrong pointer dereference
Date: Tue, 06 Mar 2012 15:15:27 -0500 (EST)
Message-ID: <20120306.151527.134916407263732962.davem@davemloft.net>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
	<1331032975-5303-5-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331032975-5303-5-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue,  6 Mar 2012 12:22:53 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> In adf7ff8, a invalid dereference was added in ebt_make_names.
> 
> CC [M]  net/bridge/netfilter/ebtables.o
> net/bridge/netfilter/ebtables.c: In function `ebt_make_names':
> net/bridge/netfilter/ebtables.c:1371:20: warning: `t' may be used uninitialized in this function [-Wuninitialized]
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
