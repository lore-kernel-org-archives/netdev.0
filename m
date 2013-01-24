From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Thu, 24 Jan 2013 13:52:34 +0100
Message-ID: <20130124125234.GL9147@secunet.com>
References: <20130124123210.GK9147@secunet.com>
 <909599053.113808.1359031070783.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47001 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953Ab3AXMwg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 07:52:36 -0500
Content-Disposition: inline
In-Reply-To: <909599053.113808.1359031070783.JavaMail.root@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 07:37:50AM -0500, Tom St Denis wrote:
> 
> Also a question for the netdev folk, in order to be timely would it be acceptable to patch ah4 and then ah6 with the AEAD changes?  Or would the team require both to be patched simultaneously?
>  

We would need patches for both, but the changes to ah4/ah6 should
e very similar.
