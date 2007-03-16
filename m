From: David Miller <davem@davemloft.net>
Subject: Re: [Devel] Re: [PATCH] Copy mac_len in skb_clone() as well
Date: Thu, 15 Mar 2007 18:08:34 -0700 (PDT)
Message-ID: <20070315.180834.39171823.davem@davemloft.net>
References: <20070314130711.GA6812@localhost.sw.ru>
	<20070315.030235.79052031.davem@davemloft.net>
	<45F920E8.4020304@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, adobriyan@sw.ru, netdev@vger.kernel.org
To: dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44486
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933942AbXCPBlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 21:41:13 -0400
In-Reply-To: <45F920E8.4020304@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Korotaev <dev@sw.ru>
Date: Thu, 15 Mar 2007 13:33:12 +0300

> David Miller wrote:
> > From: Alexey Dobriyan <adobriyan@sw.ru>
> > Date: Wed, 14 Mar 2007 16:07:11 +0300
> > 
> > 
> >>ANK says: "It is rarely used, that's wy it was not noticed.
> >>But in the places, where it is used, it should be disaster."
> >>
> >>Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
> > 
> > 
> > Applied.
> > 
> > What bug triggered that helped you discover this?  Or is it
> > merely from a code audit?
> Ohhh, it is a fairy-tale to tell the truth :)
> We had some unexplainable problems with java application in OpenVZ kernel.
> It didn't work sometimes, but worked fine (!) with CONFIG_SLAB_DEBUG.
> Alexey blamed java :), but ...
> Then we found that poising one of the bits in slab cache was curing it.
> After that we found that the problem is related to fclone cache.
> And then we found that not all the fields are initialized during cloning.
> The bug was related to our own skb->field we introduced,
> but we analyzed the code and found this as well.

Thanks for the detailed information.
