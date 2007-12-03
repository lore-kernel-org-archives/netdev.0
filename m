From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: fix lro_gen_skb() alignment
Date: Mon, 3 Dec 2007 20:29:04 +1100
Message-ID: <20071203092903.GA23149@gondor.apana.org.au>
References: <E1Iy2ey-0005eY-00@gondolin.me.apana.org.au> <475057E4.3000909@myri.com> <ada3aunlf4s.fsf@cisco.com> <4750660F.7000704@myri.com> <20071130223457.GA25388@gondor.apana.org.au> <475348BE.3010203@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, davem@davemloft.net,
	ossthema@de.ibm.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3615 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751296AbXLCJ32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 04:29:28 -0500
Content-Disposition: inline
In-Reply-To: <475348BE.3010203@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 02, 2007 at 07:07:26PM -0500, Andrew Gallatin wrote:
> 
> That was my first thought as well, but it turns out that
> when lro_gen_skb() is called via the out1 label, mac_hdr_len
> may not be known.  It seemed simplest and cleanest to just
> make it a field in lro_mgr.

Fair enough.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
