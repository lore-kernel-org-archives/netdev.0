From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Qemu-devel] [PATCH] net: add raw backend  - some performance
	measurements
Date: Tue, 21 Jul 2009 20:14:20 +0800
Message-ID: <20090721121420.GA19236@gondor.apana.org.au>
References: <20090707145739.GB14392@shareable.org> <4A54B0F1.3070201@voltaire.com> <20090715203806.GF3056@shareable.org> <4A647B72.5090404@Voltaire.com> <20090720155308.GA9327@gondor.apana.org.au> <4A656824.7070100@Voltaire.com> <20090721072546.GA16131@gondor.apana.org.au> <20090721102733.GB22155@redhat.com> <4A65A0FC.6090204@Voltaire.com> <20090721120142.GA23439@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@voltaire.com>,
	Jamie Lokier <jamie@shareable.org>,
	Anthony Liguori <anthony@codemonkey.ws>, qemu-devel@nongnu.org,
	Jan Kiszka <jan.kiszka@web.de>,
	Mark McLoughlin <markmc@redhat.com>,
	Dor Laor <dlaor@redhat.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47181 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754558AbZGUMOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 08:14:39 -0400
Content-Disposition: inline
In-Reply-To: <20090721120142.GA23439@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2009 at 03:01:42PM +0300, Michael S. Tsirkin wrote:
>
> the thing to check then would be that some kind of misconfiguration
> does not cause the bridge to flood your packets to multiple interfaces.

Right, we should make sure that the interfaces are not in promiscous
mode.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
