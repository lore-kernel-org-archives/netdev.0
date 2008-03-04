From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [ESP]: Add select on AUTHENC
Date: Tue, 04 Mar 2008 22:11:30 +0900
Message-ID: <47CD4A82.7010803@miyazawa.org>
References: <20080304121752.GA17343@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:43610 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756776AbYCDNLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 08:11:52 -0500
In-Reply-To: <20080304121752.GA17343@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

I could install an IPsec SA with your patch :-)

Thank you,

Herbert Xu wrote:
> Hi:
> 
> This patch should make the IPv6 tests work again.
> 
> [ESP]: Add select on AUTHENC
> 
> Now the ESP uses the AEAD interface even for algorithms which are
> not combined mode, we need to select CONFIG_CRYPTO_AUTHENC as
> otherwise only combined mode algorithms will work.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,

--
Kazunori Miyazawa
