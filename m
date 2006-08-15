From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use __always_inline in orinoco_lock()/orinoco_unlock()
Date: Tue, 15 Aug 2006 15:54:17 -0700 (PDT)
Message-ID: <20060815.155417.112850438.davem@davemloft.net>
References: <20060815192558.3590.63591.stgit@dv.roinet.com>
	<20060815225012.GA7612@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: proski@gnu.org, netdev@vger.kernel.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27297
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750785AbWHOWzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 18:55:20 -0400
To: davej@redhat.com
In-Reply-To: <20060815225012.GA7612@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Tue, 15 Aug 2006 18:50:12 -0400

> On Tue, Aug 15, 2006 at 03:25:58PM -0400, Pavel Roskin wrote:
> 
>  > diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
>  > index 16db3e1..8fd9b32 100644
>  > --- a/drivers/net/wireless/orinoco.h
>  > +++ b/drivers/net/wireless/orinoco.h
>  > @@ -135,11 +135,9 @@ extern irqreturn_t orinoco_interrupt(int
>  >  /********************************************************************/
>  >  
>  >  /* These functions *must* be inline or they will break horribly on
>  > - * SPARC, due to its weird semantics for save/restore flags. extern
>  > - * inline should prevent the kernel from linking or module from
>  > - * loading if they are not inlined. */
>  > -extern inline int orinoco_lock(struct orinoco_private *priv,
>  > -			       unsigned long *flags)
>  > + * SPARC, due to its weird semantics for save/restore flags. */
> 
> Didn't that get fixed up for SPARC a year or so back?

That's right, this problem no longer exists.
