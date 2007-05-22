From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [Xen-devel] Re: [PATCH 3/4] [Net] Support Xen accelerated
	network plugin modules
Date: Tue, 22 May 2007 08:59:15 +0100
Message-ID: <1179820755.4145.38.camel@moonstone.uk.level5networks.com>
References: <C2785EC4.F4E3%keir@xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	muli@il.ibm.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, herbert@gondor.apana.org.au
To: Keir Fraser <keir@xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:7759 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754962AbXEVH7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 03:59:19 -0400
In-Reply-To: <C2785EC4.F4E3%keir@xensource.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-22 at 08:48 +0100, Keir Fraser wrote:
> 
> 
> On 22/5/07 08:28, "Kieran Mansley" <kmansley@solarflare.com> wrote:
> 
> > On Tue, 2007-05-22 at 08:15 +0100, Kieran Mansley wrote:
> >> RCU on its own wouldn't
> >> prevent the accelerated plugin being unloaded while netfront was using
> >> one of the hooks.
> > 
> > Hmm, actually I think it could be used to do that.  I'll take a look.
> 
> Eagerly zap the function pointers, then wait one RCU period so every CPU
> goes through a quiescent point before unloading the module?

Yes, that's what I was going to try.  

Kieran

