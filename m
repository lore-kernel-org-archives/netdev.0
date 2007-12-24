From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about MAC address change
Date: Mon, 24 Dec 2007 15:38:01 +0200
Message-ID: <31436f4a0712240538n1b65c2a8u35109ce4c69a00d5@mail.gmail.com>
References: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
	 <E1J6RPh-0004mf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:59986 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbXLXNiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 08:38:02 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2692795wah.23
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 05:38:02 -0800 (PST)
In-Reply-To: <E1J6RPh-0004mf-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

First, it indeed can be handled by user space. (even though it should
be done twice, once for ifconig of net-tools  and once for ip of
iproute2) / However, we have already
methods which deal with bringing down an interface - neigh_ifdown(),
and changing MAC address of an interface (neigh_changeaddr). So why
not do it from
the kernel ?
DS

On Dec 23, 2007 4:02 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> David Shwatrz <dshwatrz@gmail.com> wrote:
> >
> > Hi,
> > Oop, I am TWICE sorry ! I wrongly attached a wrong, empty file.
> > Attached here is the patch.
> >
> > Regarding your answer;  I accept it and I will soon send a revised
> > version of this patch (making changes to
> > arp_netdev_event() and ndisc_netdev_event().)
> > I had  IPv4 in mind, there is no reason that it will no be also in IPv6.
>
> Hmm, why can't you do this from user-space?
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
