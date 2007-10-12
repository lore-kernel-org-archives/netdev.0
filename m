From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e100 problems in .23rc8 ?
Date: Fri, 12 Oct 2007 23:35:50 +0800
Message-ID: <20071012153550.GB28708@gondor.apana.org.au>
References: <46FAA083.9020604@intel.com> <E1IanKN-0003ju-00@gondolin.me.apana.org.au> <20071011003638.GA27174@redhat.com> <20071011012520.GA13160@gondor.apana.org.au> <470E4AFA.60507@intel.com> <20071011172551.GA21339@redhat.com> <7DCDA0F058071B49AED9D3D7886C41BE0A43AD1D@muon.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	esandeen@redhat.com
To: David Mack <dmack@juniper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2972 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754370AbXJLPim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 11:38:42 -0400
Content-Disposition: inline
In-Reply-To: <7DCDA0F058071B49AED9D3D7886C41BE0A43AD1D@muon.jnpr.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 12, 2007 at 07:54:33AM -0700, David Mack wrote:
> Still no joy here. See attached capture. What's really weird is that it
> shows *two* kernel panics, one in  e100_poll and one in _list_add.

Yes that's the symptom one would expect from that bug.  We really
need to apply the same fix that was done for e1000.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
