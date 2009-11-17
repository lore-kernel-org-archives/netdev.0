From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Tue, 17 Nov 2009 09:02:38 +0800
Message-ID: <20091117010238.GA10029@gondor.apana.org.au>
References: <4AF98A8C.9040201@novell.com> <20091114011229.GA18580@gondor.apana.org.au> <4AFE08EF.2030308@gmail.com> <20091113.190438.78469912.davem@davemloft.net> <4B016041.5030000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ghaskins@novell.com,
	mst@redhat.com, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43064 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755393AbZKQBCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 20:02:42 -0500
Content-Disposition: inline
In-Reply-To: <4B016041.5030000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2009 at 09:22:57AM -0500, Gregory Haskins wrote:
> 
> But really, this is somewhat orthogonal to the original problem, so let
> me see if we can bring it back on topic.  Michael stated that this patch
> in question may be problematic because there are places in the stack
> that can get_page() without also maintaining a reference to the shinfo
> object.  Evgeniy seems to say the opposite.  I am not sure who is right,
> or if I misunderstood one or both of them.  Any thoughts?

There are loads of places where this can happen.  Start with
pskb_expand_head.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
