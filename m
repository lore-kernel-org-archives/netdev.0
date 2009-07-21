From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Qemu-devel] [PATCH] net: add raw backend  - some performance
	measurements
Date: Tue, 21 Jul 2009 15:25:46 +0800
Message-ID: <20090721072546.GA16131@gondor.apana.org.au>
References: <20090701162115.GA4555@shareable.org> <4A4CA747.1050509@Voltaire.com> <20090703023911.GD938@shareable.org> <4A534EC4.5030209@voltaire.com> <20090707145739.GB14392@shareable.org> <4A54B0F1.3070201@voltaire.com> <20090715203806.GF3056@shareable.org> <4A647B72.5090404@Voltaire.com> <20090720155308.GA9327@gondor.apana.org.au> <4A656824.7070100@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>,
	Anthony Liguori <anthony@codemonkey.ws>, qemu-devel@nongnu.org,
	Jan Kiszka <jan.kiszka@web.de>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Mark McLoughlin <markmc@redhat.com>,
	Dor Laor <dlaor@redhat.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@Voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57541 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751583AbZGUH0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 03:26:05 -0400
Content-Disposition: inline
In-Reply-To: <4A656824.7070100@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2009 at 10:03:00AM +0300, Or Gerlitz wrote:
> 
> okay, when setting net.bridge.bridge-nf-call-iptables to zero, the VM TX / tap+bridge packet rate climbs from 170K to 195K but it still way beyond the 240K rate achieved by the raw mode --> we have now a clear sign on the performance gain this approach provides. 

I find this hard to believe this bridge sans netfilter does a
single lookup based on the MAC address and then just passes the
packet to the underlying driver.

Can you do an oprofile run to see if something else is chewing
up CPU time under the guise of bridging?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
