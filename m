From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: do not manually initialize enumerators
Date: Sat, 1 Jun 2013 22:05:09 -0600
Message-ID: <20130602040509.GD26681@mail.gmail.com>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
 <1370139797-8912-2-git-send-email-sakiwit@gmail.com>
 <1370140803.2086.0.camel@joe-AO722>
 <20130602031813.GC26681@mail.gmail.com>
 <1370143454.2086.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:54195 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab3FBEGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 00:06:38 -0400
Received: by mail-ie0-f182.google.com with SMTP id 9so2076727iec.41
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 21:06:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1370143454.2086.8.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 01 Jun 2013 20:24:14 -0700
>
> On Sat, 2013-06-01 at 21:18 -0600, Jean Sacren wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Sat, 01 Jun 2013 19:40:03 -0700
> > >
> > > On Sat, 2013-06-01 at 20:23 -0600, Jean Sacren wrote:
> > > > Clean up unnecessary initialization of enumerators as the compiler takes
> > > > care of that.
> > > []
> > > > diff --git a/include/linux/net.h b/include/linux/net.h
> > > []
> > > >  enum sock_shutdown_cmd {
> > > > -	SHUT_RD		= 0,
> > > > -	SHUT_WR		= 1,
> > > > -	SHUT_RDWR	= 2,
> > > > +	SHUT_RD,
> > > > +	SHUT_WR,
> > > > +	SHUT_RDWR,
> > > >  };
> > > 
> > > The compiler may do the same thing,
> > > but specificity is good.
> > 
> > Thank you for your input. Could you elaborate on 'specificity' in this
> > specific case?
> 
> Wpecifically, it's easier to see what the particular
> SHUT_<foo> value is when you grep for without looking
> through and counting the entire enum.

You don't need to look through and count. 'wc -l' shall tell and it's a
very small number.

With the specificity, it undervalues the power of the order of those
three enumerators. Nevertheless, I enjoyed learning from you and it's
better than SNL.

-- 
Jean Sacren
