From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Tue, 15 Sep 2009 08:31:51 -0500
Message-ID: <20090915133151.GA28431@gondor.apana.org.au>
References: <20090910125929.GA32593@redhat.com> <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com> <20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com> <20090914091151.GE14030@redhat.com> <4AAE1026.4090702@voltaire.com> <20090914101012.GA14176@redhat.com> <4AAE4DFC.9080500@voltaire.com> <20090914150313.GA18560@gondor.apana.org.au> <4AAF906B.4040608@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@Voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47907 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753899AbZIONcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 09:32:01 -0400
Content-Disposition: inline
In-Reply-To: <4AAF906B.4040608@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2009 at 04:02:35PM +0300, Or Gerlitz wrote:
>
> Yes, I am aware that GSO can take action and so software segmentation is / can be done when the HW isn't capable of doing so (and I assume the same can go for checksum). I assume that by "we provide" you mean the core networking code, correct? in what level? I assume its not the TCP one, since this is not applicable a tun/bridge scheme. Simper example would be the vm nic MTU... with vhost attached directly to a nic with packet socket you can learn/control it all, where when tun/bridge is used, how can you tell?

You handle it the same way as how you've always done with MTUs,
ensure that the MTU is set to the maximum required by all the
guests.  If that means the guests cannot use jumboframes then
that's what you're stuck with.

This is the whole reason why TSO exists in the first place.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
