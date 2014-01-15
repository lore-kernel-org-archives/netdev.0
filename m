From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] reciprocal_divide: correction/update of the algorithm
Date: Wed, 15 Jan 2014 16:02:53 +0100
Message-ID: <20140115150253.GG19945@order.stressinduktion.org>
References: <20140113214249.GK6586@order.stressinduktion.org> <52D57BAB.5070709@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	darkjames-ws@darkjames.pl
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39508 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbaAOPCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 10:02:54 -0500
Content-Disposition: inline
In-Reply-To: <52D57BAB.5070709@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 10:02:19AM -0800, Randy Dunlap wrote:
> Just trivia (coding style and spelling):
> 
> > diff --git a/lib/reciprocal_div.c b/lib/reciprocal_div.c
> > index 75510e9..b741b30 100644
> > --- a/lib/reciprocal_div.c
> > +++ b/lib/reciprocal_div.c
> > @@ -1,11 +1,25 @@
> > +#include <linux/kernel.h>
> >  #include <asm/div64.h>
> >  #include <linux/reciprocal_div.h>
> >  #include <linux/export.h>
> >  
> > -u32 reciprocal_value(u32 k)
> > +/* For a description of the algorithmus please look at
> 
>                                algorithms
> 
> > + * linux/reciprocal_div.h
> > + */
> 
> and kernel coding style for multi-line comments is like so:
> 
> /*
>  * For a description of the algorithms, please look at
>  * linux/reciprocal_div.h
>  */
> 
> > +
> > +struct reciprocal_value reciprocal_value(u32 d)
> >  {

Thanks, fixed those stuff locally along with a better description. I am
used to netdev comments. ;)
