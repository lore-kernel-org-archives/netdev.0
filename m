From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12515] New: possible circular locking #0:
	(sk_lock-AF_PACKET){--..}, at: [<c1279838>]
	sock_setsockopt+0x12b/0x4a4
Date: Sat, 31 Jan 2009 09:01:28 +1100
Message-ID: <20090130220128.GA11381@gondor.apana.org.au>
References: <497FB1C4.3000602@ribosome.natur.cuni.cz> <20090130124947.GA6886@gondor.apana.org.au> <20090130135617.GA16106@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin =?utf-8?Q?MOKREJ=C5=A0?= <mmokrejs@ribosome.natur.cuni.cz>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, vegard.nossum@gmail.com,
	a.p.zijlstra@chello.nl, davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37835 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753343AbZA3WBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:01:41 -0500
Content-Disposition: inline
In-Reply-To: <20090130135617.GA16106@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 01:56:17PM +0000, Jarek Poplawski wrote:
>
> > I resisted the temptation to create a new spin lock because the
> > mmap path isn't exactly common.
> 
> So, Dave is stronger than the temptation...

Heh, that sentence should be removed from the description.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
