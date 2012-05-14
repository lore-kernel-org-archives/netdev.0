From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/6] netfilter: decnet: switch hook PFs to nfproto
Date: Mon, 14 May 2012 15:18:16 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F0A@saturn3.aculab.com>
References: <1337003799-2517-2-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Vincent Sanders" <vincent.sanders@collabora.co.uk>,
	"Javier Martinez Canillas" <javier.martinez@collabora.co.uk>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Alban Crequy" <alban.crequy@collabora.co.uk>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>,
	"Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49172 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756440Ab2ENOSt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 10:18:49 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19268-07 for <netdev@vger.kernel.org>;
 Mon, 14 May 2012 15:18:46 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1337003799-2517-2-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> NFPROTO_* constants were usually equal to PF_* constants but it is not
> necessary and it will waste less memory if we don't do so 
> (see commit 7e9c6e
> "netfilter: Introduce NFPROTO_* constants")
...
>  
>  static struct nf_hook_ops dnrmg_ops __read_mostly = {
>  	.hook		= dnrmg_hook,
> -	.pf		= PF_DECnet,
> +	.pf		= NFPROTO_DECNET,
>  	.hooknum	= NF_DN_ROUTE,
>  	.priority	= NF_DN_PRI_DNRTMSG,
>  };

Might it be worth renaming the .pf member to (say) .nfproto
to help avoid confusion?

	David
