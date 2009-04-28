From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Tue, 28 Apr 2009 14:12:25 +0800
Message-ID: <20090428061225.GA1591@gondor.apana.org.au>
References: <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59316 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751288AbZD1GMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 02:12:33 -0400
Content-Disposition: inline
In-Reply-To: <20090427080501.GA21433@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 04:05:01PM +0800, Herbert Xu wrote:
> On Fri, Apr 24, 2009 at 12:16:08PM -0400, Andrew Gallatin wrote:
> >
> > These results are indeed quite close, so the performance problem seems
> > isolated to AMD CPUS, and perhaps due to the smaller caches.
> > Do you have any AMD you can use as a receiver?
> 
> I now have an AMD with 512K cache to test this.  Unfortunately
> I'd just locked it up before I got a chance to do any serious
> testing.  So it might take a while.

OK that's been fixed up.  Indeed the AMD can't do wire speed.
But still the performance seems comparable.  Both of them sit
between 6600Mb/s and 7100Mb/s.  The sender is running at about
66% idle in either case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
