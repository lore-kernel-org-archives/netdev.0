From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH] Use __always_inline in orinoco_lock()/orinoco_unlock()
Date: Tue, 15 Aug 2006 19:14:32 -0400
Message-ID: <1155683672.5140.1.camel@dv>
References: <20060815192558.3590.63591.stgit@dv.roinet.com>
	 <20060815225012.GA7612@redhat.com>
	 <20060815.155417.112850438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:59841 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1750800AbWHOXPN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 19:15:13 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1GD87r-0002gq-Ot
	for netdev@vger.kernel.org; Tue, 15 Aug 2006 19:15:12 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060815.155417.112850438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 15:54 -0700, David Miller wrote:
> >  >  /* These functions *must* be inline or they will break horribly on
> >  > - * SPARC, due to its weird semantics for save/restore flags. extern
> >  > - * inline should prevent the kernel from linking or module from
> >  > - * loading if they are not inlined. */
> >  > -extern inline int orinoco_lock(struct orinoco_private *priv,
> >  > -			       unsigned long *flags)
> >  > + * SPARC, due to its weird semantics for save/restore flags. */
> > 
> > Didn't that get fixed up for SPARC a year or so back?
> 
> That's right, this problem no longer exists.

Then, I guess, "static inline" would be just fine, right?

-- 
Regards,
Pavel Roskin


