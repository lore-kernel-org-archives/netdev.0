From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RPS and forwarding
Date: Mon, 26 Apr 2010 12:53:16 +0800
Message-ID: <20100426045316.GA21810@gondor.apana.org.au>
References: <20100426022415.GA20323@gondor.apana.org.au> <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48187 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750831Ab0DZExY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 00:53:24 -0400
Content-Disposition: inline
In-Reply-To: <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 09:44:05PM -0700, Tom Herbert wrote:
> 
> I think you'd want RPS on router (steering packets using hash and CPU
> mask).  Most of your concerns are about RFS (steering by flows), which
> is probably more appropriate for a server.

Right.  The problem is that if you run a distribution kernel on
a router with CONFIG_RPS (and hence RFS) enabled, you may suddenly
start seeing packet reordering on forwarded traffic due to the
presence of local traffic.

Can we perhaps add a run-time toggle to disable RFS?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
