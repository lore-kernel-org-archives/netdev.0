From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: add route suppression based on ifgroup
Date: Thu, 1 Aug 2013 18:55:24 +0200
Message-ID: <20130801165524.GF21970@zirkel.wertarbyte.de>
References: <20130801151809.GB21970@zirkel.wertarbyte.de>
 <1375373194.10515.158.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:41660 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756427Ab3HAQzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 12:55:25 -0400
Content-Disposition: inline
In-Reply-To: <1375373194.10515.158.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb Eric Dumazet (eric.dumazet@gmail.com):

> > diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
> > index 2f286dc..4d32ecc 100644
> > --- a/include/net/fib_rules.h
> > +++ b/include/net/fib_rules.h
> > @@ -19,6 +19,7 @@ struct fib_rule {
> >  	u32			flags;
> >  	u32			table;
> >  	u8			table_prefixlen_min;
> > +	int			suppress_ifgroup;
> >  	u8			action;
> >  	u32			target;
> >  	struct fib_rule __rcu	*ctarget;
> 
> Why adding holes in this structure ?

What do you mean? Adding holes?
