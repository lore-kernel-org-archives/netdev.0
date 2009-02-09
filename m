From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 9 Feb 2009 16:58:48 +1100
Message-ID: <20090209055848.GA3889@gondor.apana.org.au>
References: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com> <20090206031025.GA3281@gondor.apana.org.au> <b6a2187b0902052139p3be2f321ucd900cc5346bff8c@mail.gmail.com> <20090206054541.GA4954@gondor.apana.org.au> <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jeff Chua <jeff.chua.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34899 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751862AbZBIF7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 00:59:09 -0500
Content-Disposition: inline
In-Reply-To: <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 07:35:50PM +0800, Jeff Chua wrote:
>
> > Did you change the kernel on the other side during these tests?
> 
> No. Was hoping that the traces would show where it hang for the good
> and bad trace.

Then the problem isn't my patch at all.  My patch only affects
the side sending the urgent data, according to your straces, rlogin
is only receiving urgent data, not sending it.  So the patch cannot
have an affect.

> > If reverting the patch on the other side does fix the problem
> > for you, please do the two straces there.
> 
> Sorry, forgot to send the good trace run for the patched remote side.
> Here's attached. t5.good.

No you're still stracing rlogin, which in this case is the receiver
of the urgent data.  Please strace the sending side, which would be
presumably be rlogind in this case.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
