From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][IPSEC]: Aggregate make_jiffies
Date: Tue, 15 Aug 2006 22:59:46 -0400
Message-ID: <1155697186.5122.43.camel@jzny2>
References: <1155693500.5122.39.camel@jzny2>
	 <20060816023349.GA24174@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:59292 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750856AbWHPC7s
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 22:59:48 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GDBdK-0007Qi-Bk
	for netdev@vger.kernel.org; Tue, 15 Aug 2006 22:59:54 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060816023349.GA24174@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-16-08 at 12:33 +1000, Herbert Xu wrote:
> On Tue, Aug 15, 2006 at 09:58:19PM -0400, jamal wrote:

> > +static inline unsigned long make_jiffies(long secs)
> > +{
> > +	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
> > +		return MAX_SCHEDULE_TIMEOUT-1;
> > +	else
> > +		return secs*HZ;
> > +}
> 
> This name is probably too generic for net/xfrm.h. 

agreed. 

>  How about moving
> it to linux/jiffies.h and rewrite in the style of msec_to_jiffies?
> 

Is there something other than the boundary check already done you
foresee being made? If yes, do you wanna take a crack at it?

cheers,
jamal

