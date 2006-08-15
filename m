From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use __always_inline in orinoco_lock()/orinoco_unlock()
Date: Tue, 15 Aug 2006 16:26:48 -0700 (PDT)
Message-ID: <20060815.162648.31447745.davem@davemloft.net>
References: <20060815225012.GA7612@redhat.com>
	<20060815.155417.112850438.davem@davemloft.net>
	<1155683672.5140.1.camel@dv>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39659
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750813AbWHOX1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 19:27:42 -0400
To: proski@gnu.org
In-Reply-To: <1155683672.5140.1.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>
Date: Tue, 15 Aug 2006 19:14:32 -0400

> On Tue, 2006-08-15 at 15:54 -0700, David Miller wrote:
> > >  >  /* These functions *must* be inline or they will break horribly on
> > >  > - * SPARC, due to its weird semantics for save/restore flags. extern
> > >  > - * inline should prevent the kernel from linking or module from
> > >  > - * loading if they are not inlined. */
> > >  > -extern inline int orinoco_lock(struct orinoco_private *priv,
> > >  > -			       unsigned long *flags)
> > >  > + * SPARC, due to its weird semantics for save/restore flags. */
> > > 
> > > Didn't that get fixed up for SPARC a year or so back?
> > 
> > That's right, this problem no longer exists.
> 
> Then, I guess, "static inline" would be just fine, right?

Yep.
