From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH 0/2] AES-XCBC-MAC
Date: Wed, 14 Jun 2006 00:43:36 +0900
Message-ID: <1150213416.4200.34.camel@hookipa>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:53389 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S932141AbWFMPnr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 11:43:47 -0400
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, 

I send two patches which introduce AES-XCBC-MAC.
I changed approach to implement it with introducing
abstruct interface "keyed_hash" into crypto_tfm.
Both HMAC and XCBC use the interface.

I put kht_* outside of crt_u because keyed_hash uses
pure digest algorithm or encryption algorithm.
I think it is reasonable.

If these patches are accepted, I will send glue patches
to IPsec stack.

These are against linux-2.6.17-rc6.

Thank you,

#Yoshifuji-san, would you ack these patch again?

--
Kazunori Miyazawa


