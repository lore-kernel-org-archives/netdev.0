From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 3 May 2006 21:56:53 +1000
Message-ID: <20060503115653.GA1353@gondor.apana.org.au>
References: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au> <4458A6C1.90103@corky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20753 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965159AbWECL44
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 07:56:56 -0400
To: Just Marc <marc@corky.net>
Content-Disposition: inline
In-Reply-To: <4458A6C1.90103@corky.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 03, 2006 at 01:49:05PM +0100, Just Marc wrote:
>
> You're right, actually this box serves http/ftp file transfers only, 
> it's a mirror with a large amount of downloads a day.

That's interesting.  The RX bug that I fixed earlier would usually
manifest itself under exactly these conditions.  Alas you're running
a fixed kernel.

> I gave it another look, many of the prints are repeat prints for the 
> same remote IPs,

Can you take a tcpdump of the TCP sessions involving those IPs and
then show me the sections that occur when those messages are triggered?

> I agree, however, I think it's pretty good to allow an admin to toggle 
> it off completely.  Maybe that's all we need, really.

The question is always what you want to be off and what to leave on.
After all, you can turn off all printk's to the console through /proc.
If you also tell klogd to ignore them then you won't see anything at
all (unless you run dmesg).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
