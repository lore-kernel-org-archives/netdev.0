From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] Use __always_inline in orinoco_lock()/orinoco_unlock()
Date: Tue, 15 Aug 2006 18:50:12 -0400
Message-ID: <20060815225012.GA7612@redhat.com>
References: <20060815192558.3590.63591.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:16841 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750766AbWHOWvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 18:51:21 -0400
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <20060815192558.3590.63591.stgit@dv.roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 03:25:58PM -0400, Pavel Roskin wrote:

 > diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
 > index 16db3e1..8fd9b32 100644
 > --- a/drivers/net/wireless/orinoco.h
 > +++ b/drivers/net/wireless/orinoco.h
 > @@ -135,11 +135,9 @@ extern irqreturn_t orinoco_interrupt(int
 >  /********************************************************************/
 >  
 >  /* These functions *must* be inline or they will break horribly on
 > - * SPARC, due to its weird semantics for save/restore flags. extern
 > - * inline should prevent the kernel from linking or module from
 > - * loading if they are not inlined. */
 > -extern inline int orinoco_lock(struct orinoco_private *priv,
 > -			       unsigned long *flags)
 > + * SPARC, due to its weird semantics for save/restore flags. */

Didn't that get fixed up for SPARC a year or so back?

		Dave

-- 
http://www.codemonkey.org.uk
