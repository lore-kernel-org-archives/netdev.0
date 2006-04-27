From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Netpoll checksum issue
Date: Fri, 28 Apr 2006 07:29:12 +1000
Message-ID: <20060427212912.GB23413@gondor.apana.org.au>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com> <20060419103153.64ef0054@localhost.localdomain> <6d6a94c50604191854m73b241e3v104d713b7bb93674@mail.gmail.com> <20060423113432.GA16424@gondor.apana.org.au> <6d6a94c50604232242hd091922q8a2a0c78f1163b3c@mail.gmail.com> <20060424102250.GA24437@gondor.apana.org.au> <6d6a94c50604240622v4cc3f0efi20429b474927c814@mail.gmail.com> <6d6a94c50604270557w434945d2v4b934c328abaa92e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15886 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751189AbWD0V3Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 17:29:25 -0400
To: Aubrey <aubreylee@gmail.com>
Content-Disposition: inline
In-Reply-To: <6d6a94c50604270557w434945d2v4b934c328abaa92e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 27, 2006 at 08:57:33PM +0800, Aubrey wrote:
> 
> Is there any update of this issue?

Assuming that the CHECKSUM_UNNECESSARY line wasn't there, then the
problem is simply that your packet has the wrong UDP checksum.
So I suggest that you print the packet out and compare it with
the original to see where the corruption is.

I don't see how the generic networking stack or netpoll could be
causing your problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
