From: James Morris <jmorris@namei.org>
Subject: Re: [RFC][PATCH][XFRM][1/5] extension to XFRM for dynamic endpoint
 update (MIGRATE)
Date: Fri, 2 Feb 2007 07:51:14 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0702020747340.16188@d.namei>
References: <20070201113017.E2BA.SHINTA@sfc.wide.ad.jp>
 <Pine.LNX.4.64.0702010937250.8524@d.namei> <20070202203550.E2F3.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:52349 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933386AbXBBMvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 07:51:18 -0500
In-Reply-To: <20070202203550.E2F3.SHINTA@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Feb 2007, Shinta Sugimoto wrote:

> > 
> > > +EXPORT_SYMBOL(xfrm_state_clone);
> > 
> > Why not EXPORT_SYMBOL_GPL ?
> > (for all of your exports).
> 
> Actually I don't have specific preference on either EXPORT_SYMBOL or
> EXPORT_SYMBOL_GPL.  It seemed to me that other functions defined in
> files under net/xfrm/ are using EXPORT_SYMBOL, so I followed that.

Hmm, you're right, most of them are not _GPL.

> Do you think EXPORT_SYMBOL_GPL is more appropriate in this case?

Well, I would have thought that users of xfrm were generally derivative of 
the kernel, but it doesn't make much sense to have only a couple of 
symbols exported as GPL, so probably keep it the way you already have it.


- James
-- 
James Morris
<jmorris@namei.org>
