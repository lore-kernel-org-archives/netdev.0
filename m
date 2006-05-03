From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 3 May 2006 23:19:52 +1000
Message-ID: <20060503131952.GA26069@gondor.apana.org.au>
References: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au> <4458A6C1.90103@corky.net> <20060503115653.GA1353@gondor.apana.org.au> <Pine.NEB.4.62.0605031206040.18261@otaku.freeshell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Just Marc <marc@corky.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:24083 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030195AbWECNT6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 09:19:58 -0400
To: Alexey Toptygin <alexeyt@freeshell.org>
Content-Disposition: inline
In-Reply-To: <Pine.NEB.4.62.0605031206040.18261@otaku.freeshell.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 03, 2006 at 12:15:30PM +0000, Alexey Toptygin wrote:
> 
> I'm curious, how would you do this without filling the disk? With a script 
> that starts tcpdump to a ring in the background, waits for the offending 
> log entry to appear and then kills tcpdump?

Well if you know the set of IPs that's likely to cause this you just
run tcpdump with an expression to filter out all traffic but those
IPs.

Sinec tcpdump only captures 100 bytes of each packet by default, it
should be manageable assuming that this problem occurs relatively
frequently.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
