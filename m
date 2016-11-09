From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 4/5] net: l2tp: cleanup: remove redundant
 condition
Date: Wed, 09 Nov 2016 18:56:43 -0500 (EST)
Message-ID: <20161109.185643.1145389940936719190.davem@davemloft.net>
References: <20161107203928.30111-1-asbjorn@asbjorn.st>
        <20161107203928.30111-4-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: asbjorn@asbjorn.st
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107203928.30111-4-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Date: Mon,  7 Nov 2016 20:39:27 +0000

> These assignments follow this pattern:
> 
> 	unsigned int foo:1;
> 	struct nlattr *nla = info->attrs[bar];
> 
> 	if (nla)
> 		foo = nla_get_flag(nla); /* expands to: foo = !!nla */
> 
> This could be simplified to: if (nla) foo = 1;
> but lets just remove the condition and use the macro,
> 
> 	foo = nla_get_flag(nla);
> 
> Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>

Applied.
