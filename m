From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] act_nat: fix the wrong checksum when addr isn't in
	old_addr/mask
Date: Mon, 31 May 2010 07:53:22 +1000
Message-ID: <20100530215322.GA11253@gondor.apana.org.au>
References: <1275179219-10424-1-git-send-email-xiaosuo@gmail.com> <1275223421.3587.0.camel@bigi> <20100530125811.GA8120@gondor.apana.org.au> <AANLkTinDe-AluGZx87q3nvxCfushfeH0jS35Fav95IXk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:33289 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754978Ab0E3Vxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 17:53:36 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinDe-AluGZx87q3nvxCfushfeH0jS35Fav95IXk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 30, 2010 at 09:33:22PM +0800, Changli Gao wrote:
>
> Thinking about this topologic:
> 
> client -> DNAT -> router -> server.
> 
> DNAT is used to map a public IP to server's private IP. If a
> DEST_UNREACH ICMP packet is sent out by router, in order to handle
> this ICMP packet correctly, I have to pass it to act_nat.c. How can I
> filter out the other packets? By inspecting the inner IP destination
> address of this ICMP packet? Maybe I can use u32 with complicate
> parameters.

You should filter out all the non-ICMP packets, just like you
do here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
