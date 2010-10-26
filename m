From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: reset gso header when the copied skb is linearized
Date: Tue, 26 Oct 2010 15:38:32 -0400
Message-ID: <20101026193832.GA13747@gondor.apana.org.au>
References: <1288045398-3110-1-git-send-email-fleitner@redhat.com> <20101026.113157.233700961.davem@davemloft.net> <20101026192511.GA3494@redhat.com> <20101026.122801.52191238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fleitner@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35783 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758133Ab0JZTih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:38:37 -0400
Content-Disposition: inline
In-Reply-To: <20101026.122801.52191238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 12:28:01PM -0700, David Miller wrote:
>
> Thus, if we linearize a larger than MSS sized frame, it should still
> have the same GSO attributes.

I agree with you on all counts :)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
