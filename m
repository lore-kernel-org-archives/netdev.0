From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Tue, 15 Sep 2009 16:02:35 +0300
Message-ID: <4AAF906B.4040608@Voltaire.com>
References: <20090910125929.GA32593@redhat.com>	<15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com>	<20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com>	<20090914091151.GE14030@redhat.com> <4AAE1026.4090702@voltaire.com>	<20090914101012.GA14176@redhat.com> <4AAE4DFC.9080500@voltaire.com> <20090914150313.GA18560@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:25421 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752587AbZIONCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 09:02:33 -0400
In-Reply-To: <20090914150313.GA18560@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> TSO is not a problem because we provide a software fallback when
> the hardware does not support it.  So guests should always enable
> TSO if they support it and not worry about the physical NIC.

Yes, I am aware that GSO can take action and so software segmentation is / can be done when the HW isn't capable of doing so (and I assume the same can go for checksum). I assume that by "we provide" you mean the core networking code, correct? in what level? I assume its not the TCP one, since this is not applicable a tun/bridge scheme. Simper example would be the vm nic MTU... with vhost attached directly to a nic with packet socket you can learn/control it all, where when tun/bridge is used, how can you tell?

Or.
