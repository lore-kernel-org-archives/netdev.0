From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fib_rules: add route suppression based on ifgroup
Date: Thu, 01 Aug 2013 10:05:02 -0700
Message-ID: <1375376702.10515.171.camel@edumazet-glaptop>
References: <20130801151809.GB21970@zirkel.wertarbyte.de>
	 <1375373194.10515.158.camel@edumazet-glaptop>
	 <20130801165524.GF21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:63002 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755708Ab3HARFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 13:05:04 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so2258030pde.10
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 10:05:03 -0700 (PDT)
In-Reply-To: <20130801165524.GF21970@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 18:55 +0200, Stefan Tomanek wrote:
> Dies schrieb Eric Dumazet (eric.dumazet@gmail.com):
> 
> > > diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
> > > index 2f286dc..4d32ecc 100644
> > > --- a/include/net/fib_rules.h
> > > +++ b/include/net/fib_rules.h
> > > @@ -19,6 +19,7 @@ struct fib_rule {
> > >  	u32			flags;
> > >  	u32			table;
> > >  	u8			table_prefixlen_min;
> > > +	int			suppress_ifgroup;
> > >  	u8			action;
> > >  	u32			target;
> > >  	struct fib_rule __rcu	*ctarget;
> > 
> > Why adding holes in this structure ?
> 
> What do you mean? Adding holes?

http://linux.die.net/man/1/pahole
