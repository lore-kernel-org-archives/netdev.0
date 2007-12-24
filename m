From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: ipv4_devconf.arp_accept mystery
Date: Mon, 24 Dec 2007 15:46:16 +0200
Message-ID: <d0383f90712240546u675fcc07m2314af35920a39ec@mail.gmail.com>
References: <d0383f90712230800n6e6d6b92x64eaa8dcff313915@mail.gmail.com>
	 <E1J6mmW-0006dP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:33613 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbXLXNqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 08:46:25 -0500
Received: by py-out-1112.google.com with SMTP id u77so2882773pyb.16
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 05:46:16 -0800 (PST)
In-Reply-To: <E1J6mmW-0006dP-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

>As the name suggests you should use
>     /proc/sys/net/ipv4/conf/all/arp_accept
 Thanks. This is indeed true.
I first tried with ipv4_devconf.arp_accept, where the name probably
does **not** suggest it; I agree
that  for PV4_DEVCONF_ALL() the name indeed suggests it . It just
skipped my eye. I suppose this is true also to
ipv4_devconf.arp_accept.

Rgs,
Ian



On Dec 24, 2007 2:51 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Ian Brown <ianbrn@gmail.com> wrote:
> >
> > BTW, in newer kernel version we have IPV4_DEVCONF_ALL(ARP_ACCEPT)
> > instead. So if anybody knows how to set this macro (instead)to be 1, it will be
> > also fine.
>
> As the name suggests you should use
>
>         /proc/sys/net/ipv4/conf/all/arp_accept
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
