From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e100 problems in .23rc8 ?
Date: Sat, 13 Oct 2007 10:35:37 +0800
Message-ID: <E1IgWqn-0000iU-00@gondolin.me.apana.org.au>
References: <7DCDA0F058071B49AED9D3D7886C41BE0A43AD2F@muon.jnpr.net>
Cc: herbert@gondor.apana.org.au, davej@redhat.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	esandeen@redhat.com
To: dmack@juniper.net (David Mack)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1981 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750839AbXJMCgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 22:36:13 -0400
In-Reply-To: <7DCDA0F058071B49AED9D3D7886C41BE0A43AD2F@muon.jnpr.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Mack <dmack@juniper.net> wrote:
> If I understand the message Dave Jones sent yesterday, the patch you
> mention *was* applied to the e100 driver in 2.6.23-6.fc8?

Nope, he applied a different one which doesn't have the crucial
part to disable NAPI polls before registration.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
