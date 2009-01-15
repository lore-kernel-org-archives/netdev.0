From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH - REPOST] asix.c - Add support for AX88772A devices -
Date: Wed, 14 Jan 2009 21:38:31 -0800 (PST)
Message-ID: <20090114.213831.222765392.davem@davemloft.net>
References: <1231949520.4105.97.camel@dhollis-lnx>
	<1231952036.3010.21.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhollis@davehollis.com, jeff@garzik.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754085AbZAOFia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:38:30 -0500
In-Reply-To: <1231952036.3010.21.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 14 Jan 2009 16:53:56 +0000

> On Wed, 2009-01-14 at 11:12 -0500, David Hollis wrote:
> > The attached patch adds support for ASIX AX88772A devices, which is used
> > in some netbooks, notebooks and embedded devices.  It's largely
> > compatible with the AX88772 family.
> > 
> > This re-post does not include changes to the ax88772_link_reset()
> > function that removed the use of the generic MII calls in favor of more
> > explicit register reads.  Those changes were not required for AX88772A
> > support.
> > 
> > Thanks to Louis <louis@asix.com.tw> for the initial patch.
> > 
> > Signed-off-by: David Hollis <dhollis@davehollis.com>
> 
> This patch, including the context, has had tabs converted to spaces.  

That's why he used an attachment.

I applied David's patch as-is, we can clean this code up later.
