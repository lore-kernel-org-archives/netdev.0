From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: avoid double free in nf_reinject
Date: Sun, 07 Aug 2011 22:11:58 -0700 (PDT)
Message-ID: <20110807.221158.636741102851927559.davem@davemloft.net>
References: <alpine.LFD.2.00.1108051326300.1494@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, kswamy@barracuda.com
To: ja@ssi.bg
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1108051326300.1494@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Fri, 5 Aug 2011 13:36:28 +0300 (EEST)

> 
> 	NF_STOLEN means skb was already freed
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	May be fixes IPVS+ip_queue problem reported by Kumar Swamy:
> 
> 	http://marc.info/?l=linux-virtual-server&m=131098073717449&w=2

Since the netfilter maintainers are taking too damn long to integrate
bug fixes (and this has been happening for months), I'm going to apply
this directly.

Thanks Julian.
