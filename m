From: Martin Willi <martin@strongswan.org>
Subject: Re: CCM/GCM implementation defect
Date: Thu, 23 Apr 2015 15:24:59 +0200
Message-ID: <1429795499.31437.9.camel@martin>
References: <20150423032619.GA17648@gondor.apana.org.au>
	 <20150423114533.GI8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:33840 "EHLO
	mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788AbbDWNZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 09:25:03 -0400
In-Reply-To: <20150423114533.GI8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

> > It looks like our IPsec implementations of CCM and GCM are buggy
> > in that they don't include the IV in the authentication calculation.
> 
> Seems like crypto_rfc4106_crypt() passes the associated data it
> got from ESP directly to gcm, without chaining with the IV.

Do you have any pointer for me where this is defined? Why is it needed,
given that GCM implicitly authenticates the IV by using it in Y0?

Also, I've just verified that a tunnel between the Windows Filtering
Platform and Linux 3.13 using AES128GCM16 works just fine. So if we do
something wrong, the problem does not only affect Linux.

Regards
Martin
