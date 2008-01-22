From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [GIT PULL] [IPV6,IPV4]: Fix several sparse warnings.
Date: Tue, 22 Jan 2008 11:03:12 +0100
Message-ID: <20080122110312.10445043.dada1@cosmosbay.com>
References: <20080122.185632.09970660.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:33390 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754742AbYAVKDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 05:03:19 -0500
In-Reply-To: <20080122.185632.09970660.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jan 2008 18:56:32 +0900 (JST)
YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E  <yoshfuji@lin=
ux-ipv6.org> wrote:


> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index cb2411c..ecd9d91 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -418,7 +418,7 @@ out:
> =20
>  void udp_err(struct sk_buff *skb, u32 info)
>  {
> -	return __udp4_lib_err(skb, info, udp_hash);
> +	__udp4_lib_err(skb, info, udp_hash);
>  }

Hum... On this one, I would say Sparse is picky, not to say buggy :(
