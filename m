From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Sat, 26 Feb 2011 11:11:18 +0800
Message-ID: <20110226031118.GA21270@gondor.apana.org.au>
References: <20110226005718.GA19889@gondor.apana.org.au> <20110225.181244.104056532.davem@davemloft.net> <20110226024848.GA20993@gondor.apana.org.au> <20110225.190723.39180243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, tgraf@infradead.org, therbert@google.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51525 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab1BZDLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 22:11:31 -0500
Content-Disposition: inline
In-Reply-To: <20110225.190723.39180243.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 07:07:23PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 26 Feb 2011 10:48:48 +0800
> 
> > I'm looking at redoing this and the bulk of the work is going to
> > be restructuring ip_append_data/ip_push_pending_frames so that it
> > doesn't store the states in sk/inet_sk.
> 
> I suppose you're going to replace that stuff with an on-stack
> control structure that gets passed around by reference or
> similar?

Either that or have ip_append_data do ip_push_pending_frames
directly.

That function's signature is a mess already and I need to think
about this a bit more :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
