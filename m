From: Jan Engelhardt <jengelh@inai.de>
Subject: RE: [PATCH 2/6] netfilter: decnet: switch hook PFs to nfproto
Date: Mon, 14 May 2012 17:06:50 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1205141706410.11548@frira.vanv.qr>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F0A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F0A@saturn3.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2012-05-14 16:18, David Laight wrote:

> 
>> NFPROTO_* constants were usually equal to PF_* constants but it is not
>> necessary and it will waste less memory if we don't do so 
>> (see commit 7e9c6e
>> "netfilter: Introduce NFPROTO_* constants")
>...
>>  
>>  static struct nf_hook_ops dnrmg_ops __read_mostly = {
>>  	.hook		= dnrmg_hook,
>> -	.pf		= PF_DECnet,
>> +	.pf		= NFPROTO_DECNET,
>>  	.hooknum	= NF_DN_ROUTE,
>>  	.priority	= NF_DN_PRI_DNRTMSG,
>>  };
>
>Might it be worth renaming the .pf member to (say) .nfproto
>to help avoid confusion?

Yes that seems like a sensible thing.
