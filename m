From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: avoid double free in nf_reinject
Date: Mon, 8 Aug 2011 12:13:04 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1108081209010.17266@frira.zrqbmnf.qr>
References: <alpine.LFD.2.00.1108051326300.1494@ja.ssi.bg> <20110807.221158.636741102851927559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ja@ssi.bg, kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, kswamy@barracuda.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110807.221158.636741102851927559.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2011-08-08 07:11, David Miller wrote:

>From: Julian Anastasov <ja@ssi.bg>
>Date: Fri, 5 Aug 2011 13:36:28 +0300 (EEST)
>
>> 
>> 	NF_STOLEN means skb was already freed
>> 
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
>> ---
>> 
>> 	May be fixes IPVS+ip_queue problem reported by Kumar Swamy:
>> 
>> 	http://marc.info/?l=linux-virtual-server&m=131098073717449&w=2
>
>Since the netfilter maintainers are taking too damn long to integrate
>bug fixes (and this has been happening for months), I'm going to apply
>this directly.

I am offering myself as a candidate for a substitute.
