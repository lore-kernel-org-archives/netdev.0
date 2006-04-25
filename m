From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP not retransmitting supposedly lost segment
Date: Tue, 25 Apr 2006 12:42:47 +1000
Message-ID: <20060425024247.GA29782@gondor.apana.org.au>
References: <20060406171926.GA8142@florz.florz.dyndns.org> <20060410010005.GA9282@florz.florz.dyndns.org> <20060423122718.GA16504@gondor.apana.org.au> <20060423235609.GB17254@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:27662 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751346AbWDYCmx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 22:42:53 -0400
To: Florian Zumbiehl <florz@gmx.de>
Content-Disposition: inline
In-Reply-To: <20060423235609.GB17254@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2006 at 01:56:09AM +0200, Florian Zumbiehl wrote:
> 
> Well, at least the tcp part of it, it seems, yep. The debugging I've
> done so far also seems to confirm that the problem is somewhere beyond
> the tcp code, but I don't have any real clue yet ...

One way to proceed is to add printk's to the error paths in the output
path through TCP, IPv6, netfilter, ...

These should be rare so the it shouldn't flood your syslog.  Based on
which error path is taken or not taken you should be able to work out
where you need to focus your search on.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
