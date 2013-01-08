From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 0/3] Make rfc3686 template work with asynchronous
 block ciphers
Date: Tue, 8 Jan 2013 08:04:31 +0100
Message-ID: <20130108070431.GT18940@secunet.com>
References: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36278 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990Ab3AHHEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 02:04:35 -0500
Content-Disposition: inline
In-Reply-To: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2012 at 12:04:48PM +0200, Jussi Kivilinna wrote:
> I'm not sure how this patchset should be dealt with (should 1st patch go
> through different tree than 2nd and 3rd?), so therefore it's RFC.
> 
> Second patch makes rfc3686 template work with asynchronous block ciphers and
> third patch changes aesni-intel to use this template. First patch fixed problem
> in xfrm_algo found with help of 2nd and 3rd patches and without 1st patch
> 2nd patch breaks aes-ctr with IPSEC.
> 
> 
> ---
> 
> Jussi Kivilinna (3):
>       xfrm_algo: probe asynchronous block ciphers instead of synchronous
>       crypto: ctr - make rfc3686 asynchronous block cipher
>       crypto: aesni-intel - remove rfc3686(ctr(aes)), utilize rfc3686 from ctr-module instead
> 

All applied to ipsec-next.

Thanks!
