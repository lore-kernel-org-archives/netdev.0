From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv4_devconf.arp_accept mystery
Date: Mon, 24 Dec 2007 20:51:44 +0800
Message-ID: <E1J6mmW-0006dP-00@gondolin.me.apana.org.au>
References: <d0383f90712230800n6e6d6b92x64eaa8dcff313915@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: ianbrn@gmail.com (Ian Brown)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1106 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751432AbXLXMvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 07:51:48 -0500
In-Reply-To: <d0383f90712230800n6e6d6b92x64eaa8dcff313915@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Brown <ianbrn@gmail.com> wrote:
>
> BTW, in newer kernel version we have IPV4_DEVCONF_ALL(ARP_ACCEPT)
> instead. So if anybody knows how to set this macro (instead)to be 1, it will be
> also fine.

As the name suggests you should use

	/proc/sys/net/ipv4/conf/all/arp_accept

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
