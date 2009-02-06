From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Fri, 6 Feb 2009 16:45:41 +1100
Message-ID: <20090206054541.GA4954@gondor.apana.org.au>
References: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com> <20090206031025.GA3281@gondor.apana.org.au> <b6a2187b0902052139p3be2f321ucd900cc5346bff8c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jeff Chua <jeff.chua.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38368 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751183AbZBFFpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 00:45:54 -0500
Content-Disposition: inline
In-Reply-To: <b6a2187b0902052139p3be2f321ucd900cc5346bff8c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 01:39:19PM +0800, Jeff Chua wrote:
> 
> Attached are two strace. t1.good is a good rlogin run. t4.bad is bad
> rlogin run where nothing is displayed but typing "~-." gets back to
> the host.

You traced the side receiving the urgent pointer.  This has
nothing to do with the patch since it only changes sending
behaviour.

Did you change the kernel on the other side during these tests?

If reverting the patch on the other side does fix the problem
for you, please do the two straces there.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
