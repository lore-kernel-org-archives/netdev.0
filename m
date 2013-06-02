From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: do not manually initialize enumerators
Date: Sat, 1 Jun 2013 21:18:13 -0600
Message-ID: <20130602031813.GC26681@mail.gmail.com>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
 <1370139797-8912-2-git-send-email-sakiwit@gmail.com>
 <1370140803.2086.0.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:55317 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3FBDTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 23:19:42 -0400
Received: by mail-ie0-f176.google.com with SMTP id at20so7289404iec.35
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 20:19:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1370140803.2086.0.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 01 Jun 2013 19:40:03 -0700
>
> On Sat, 2013-06-01 at 20:23 -0600, Jean Sacren wrote:
> > Clean up unnecessary initialization of enumerators as the compiler takes
> > care of that.
> []
> > diff --git a/include/linux/net.h b/include/linux/net.h
> []
> >  enum sock_shutdown_cmd {
> > -	SHUT_RD		= 0,
> > -	SHUT_WR		= 1,
> > -	SHUT_RDWR	= 2,
> > +	SHUT_RD,
> > +	SHUT_WR,
> > +	SHUT_RDWR,
> >  };
> 
> The compiler may do the same thing,
> but specificity is good.

Thank you for your input. Could you elaborate on 'specificity' in this
specific case?

-- 
Jean Sacren
