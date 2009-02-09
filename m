From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Mon, 9 Feb 2009 08:28:19 -0500
Message-ID: <20090209132819.GA17405@hmsreliant.think-freely.org>
References: <20090206182020.GA24399@hmsreliant.think-freely.org> <20090206165736.295ec007@extreme> <20090207174931.GA10247@localhost.localdomain> <20090209102134.GA8492@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42547 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755936AbZBIN2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 08:28:37 -0500
Content-Disposition: inline
In-Reply-To: <20090209102134.GA8492@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2009 at 09:21:34PM +1100, Herbert Xu wrote:
> On Sat, Feb 07, 2009 at 12:49:32PM -0500, Neil Horman wrote:
> >
> > Well, as I mentioned, its totally incomplete.  I only posted it, so that you
> > could see an exemplar of how I wanted to use tracepoints to dynamically
> > intercept various in kernel events so that I could gather drop notifications. Of
> > course several other tracepoints will be needed to capture other classes of drop
> > (IPv6 stats, arp queue overflows, qdisc drops, etc).
> 
> FWIW it sounds pretty reasonable to me.  Although I'm still unsure
> on what impact all these trace points will have on the maintainence
> of our source code.
> 
I think thats a fair question, and I don't honestly know the answer.  In my
projections I expect the tracepoint to only need to be placed in the
snmpv6/6/linux macros and perhaps 3 other points.  I'll know more when I
complete the work, and the it can get a through review.

To address the performance questions, I'll certainly run some tests to compare
the number of jiffies a trace takes on baseline (CONFIG_TRACEPOINTS not set),
with tracepoints configured but not enabled, and with them enabled.

Thanks for the feedback.
Neil

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
