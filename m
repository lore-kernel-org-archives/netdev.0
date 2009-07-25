From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
	in back trace (regression)
Date: Sat, 25 Jul 2009 11:33:28 +0800
Message-ID: <20090725033328.GA30919@gondor.apana.org.au>
References: <4A68B5DA.5000307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	for.poige+bugzilla.kernel.org@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47420 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751678AbZGYDdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 23:33:39 -0400
Content-Disposition: inline
In-Reply-To: <4A68B5DA.5000307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote:
>
> Here is a link showing around pppoe problem quite similar to
> the one fixed later in pty.c by Alan Cox, so IMHO the current
> 2.6.31-rc is worth trying.

Well it depends on whether he's using the kernel pppoe stack or
doing pppoe in user-space.  If the latter then yes those fixes
may help.  Otherwise we really need to see the backtraces.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
