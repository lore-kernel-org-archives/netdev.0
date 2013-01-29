From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 5/6] net: use lib/percpu_counter API for
 fragmentation mem accounting
Date: Tue, 29 Jan 2013 08:31:30 +0100
Message-ID: <1359444690.7119.10.camel@localhost>
References: <20130124140343.14119.77712.stgit@dragon>
	 <20130124140441.14119.1878.stgit@dragon>
	 <20130128.232402.883917994065372213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, amwang@redhat.com, kaber@trash.net,
	herbert@gondor.hengli.com.au, dborkman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752480Ab3A2Hcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 02:32:36 -0500
In-Reply-To: <20130128.232402.883917994065372213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-28 at 23:24 -0500, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Thu, 24 Jan 2013 15:04:53 +0100
> 
> > diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
> > index b9df9ed..eded1aa 100644
> > --- a/include/linux/percpu_counter.h
> > +++ b/include/linux/percpu_counter.h
> > @@ -83,7 +83,7 @@ static inline int percpu_counter_initialized(struct percpu_counter *fbc)
> >  	return (fbc->counters != NULL);
> >  }
> >  
> > -#else
> > +#else /* No CONFIG_SMP */
> >  
> >  struct percpu_counter {
> >  	s64 count;
> 
> This is unrelated to your changes, please remove this from the patch.

Understood, thanks for noticing.
