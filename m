From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Sun, 27 Feb 2011 19:06:14 +0800
Message-ID: <20110227110614.GA6246@gondor.apana.org.au>
References: <20110225.112019.48513284.davem@davemloft.net> <20110226005718.GA19889@gondor.apana.org.au> <20110227110205.GE9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43941 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab1B0LGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 06:06:32 -0500
Content-Disposition: inline
In-Reply-To: <20110227110205.GE9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 27, 2011 at 06:02:05AM -0500, Thomas Graf wrote:
>
> I still suggest to merge this patch as a immediate workaround fix
> until we scale properly on a single socket and also as a workaround
> for applications which can't get rid of their per socket mutex quickly.

I disagree completely.

This patch adds a user-space API that we will have to carry
with us for perpetuity.  I would only support this if we had
no other way around the problem.

If this does turn out to be mostly due to sendmsg contention
then fixing it is going to be much simpler than making the UDP
stack multiqueue capable.

I'm working on this right now.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
