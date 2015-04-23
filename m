From: Martin Willi <martin@strongswan.org>
Subject: Re: CCM/GCM implementation defect
Date: Thu, 23 Apr 2015 11:58:52 +0200
Message-ID: <1429783132.3083.15.camel@martin>
References: <20150423032619.GA17648@gondor.apana.org.au>
	 <5538B56A.7060707@freescale.com>
	 <20150423090545.GA20369@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Horia =?UTF-8?Q?Geant=C4=83?= <horia.geanta@freescale.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:58835 "EHLO
	mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132AbbDWKIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 06:08:50 -0400
In-Reply-To: <20150423090545.GA20369@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

> > Does this mean that even the test vectors (crypto/testmgr.h) are broken?
> 
> Indeed.  The test vectors appear to be generated either through
> our implementation or by one that is identical to us.

I'm not sure about that. RFC4106 refers to [1] for test vectors, which
is still available at web.archive.org [2].

When looking for example at Test Case 3, this is the same as in a newer
revision of the document [3]. That looks exactly the same as
aes_gcm_enc_tv_template[2] from testmgr.h.

We by the way use test vectors in userland from the same document to
verify our own GCM backend, our OpenSSL backend and an AESNI/PCLMULQD
backend. And I've never heard of any incompatibilities.

Regards
Martin

[1]http://csrc.nist.gov/CryptoToolkit/modes/proposedmodes/gcm/gcm-spec.pdf
[2]http://web.archive.org/web/20070712195408/http://csrc.nist.gov/CryptoToolkit/modes/proposedmodes/gcm/gcm-spec.pdf
[3]http://csrc.nist.gov/groups/ST/toolkit/BCM/documents/proposedmodes/gcm/gcm-revised-spec.pdf
