From: "David Mack" <dmack@juniper.net>
Subject: RE: e100 problems in .23rc8 ?
Date: Fri, 12 Oct 2007 08:51:48 -0700
Message-ID: <7DCDA0F058071B49AED9D3D7886C41BE0A43AD2F@muon.jnpr.net>
References: <46FAA083.9020604@intel.com> <E1IanKN-0003ju-00@gondolin.me.apana.org.au> <20071011003638.GA27174@redhat.com> <20071011012520.GA13160@gondor.apana.org.au> <470E4AFA.60507@intel.com> <20071011172551.GA21339@redhat.com> <7DCDA0F058071B49AED9D3D7886C41BE0A43AD1D@muon.jnpr.net> <20071012153550.GB28708@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Dave Jones" <davej@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, <netdev@vger.kernel.org>,
	<esandeen@redhat.com>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og110.obsmtp.com ([64.18.2.173]:57546 "EHLO
	exprod7og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbXJLPwQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 11:52:16 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071012153550.GB28708@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If I understand the message Dave Jones sent yesterday, the patch you
mention *was* applied to the e100 driver in 2.6.23-6.fc8?

Dave 

> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
> Sent: Friday, October 12, 2007 8:36 AM
> To: David Mack
> Cc: Dave Jones; Kok, Auke; netdev@vger.kernel.org; esandeen@redhat.com
> Subject: Re: e100 problems in .23rc8 ?
> 
> On Fri, Oct 12, 2007 at 07:54:33AM -0700, David Mack wrote:
> > Still no joy here. See attached capture. What's really 
> weird is that it
> > shows *two* kernel panics, one in  e100_poll and one in _list_add.
> 
> Yes that's the symptom one would expect from that bug.  We really
> need to apply the same fix that was done for e1000.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
