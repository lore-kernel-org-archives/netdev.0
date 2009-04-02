From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 11:15:04 +0800
Message-ID: <20090402031503.GA27930@gondor.apana.org.au>
References: <200904011638.45135.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ghaskins@novell.com, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42346 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753194AbZDBDPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 23:15:18 -0400
Content-Disposition: inline
In-Reply-To: <200904011638.45135.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell <rusty@rustcorp.com.au> wrote:
> 
> As you point out, 350-450 is possible, which is still bad, and it's at least
> partially caused by the exit to userspace and two system calls.  If virtio_net
> had a backend in the kernel, we'd be able to compare numbers properly.

FWIW I don't really care whether we go with this or a kernel
virtio_net backend.  Either way should be good.  However the
status quo where we're stuck with a user-space backend really
sucks!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
