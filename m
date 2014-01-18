From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] net: remove unnecessary initializations in net_dev_init
Date: Sat, 18 Jan 2014 19:04:58 +0100
Message-ID: <20140118180458.GB23364@kria>
References: <1390057451-30807-1-git-send-email-sd@queasysnail.net>
 <1390066846.31367.538.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:52142 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbaARSFL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jan 2014 13:05:11 -0500
Content-Disposition: inline
In-Reply-To: <1390066846.31367.538.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-01-18, 09:40:46 -0800, Eric Dumazet wrote:
> On Sat, 2014-01-18 at 16:04 +0100, Sabrina Dubroca wrote:
> > softnet_data is set to 0 by memset, no need to initialize specific
> > fields to 0 or NULL afterwards.
> > 
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > ---
> >  net/core/dev.c | 9 ---------
> >  1 file changed, 9 deletions(-)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 288df62..b57b44a2 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -7000,25 +7000,16 @@ static int __init net_dev_init(void)
> >  		memset(sd, 0, sizeof(*sd));
> 
> Hi Sabrina
> 
> Well, if you really want, you also can remove this memset(), percpu data
> defined as :
> 
> DEFINE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
> 
> must also be zero at boot time.
> 
> Thanks !

Okay, I'll send a v2.
Thanks!

-- 
Sabrina
