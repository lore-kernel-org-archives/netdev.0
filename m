From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix OOPS when bridging device without ethtool
Date: Thu, 30 Aug 2007 22:16:42 -0700 (PDT)
Message-ID: <20070830.221642.41875712.davem@davemloft.net>
References: <20070830145840.GU14130@parisc-linux.org>
	<20070830082932.71272c3d@freepuppy.rosehill.hemminger.net>
	<20070830164812.GW14130@parisc-linux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, johannes@sipsolutions.net,
	voss@seehuhn.de, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	bridge@linux-foundation.org
To: matthew@wil.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58893
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753855AbXHaFQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:16:43 -0400
In-Reply-To: <20070830164812.GW14130@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 30 Aug 2007 10:48:13 -0600

> On Thu, Aug 30, 2007 at 08:29:32AM -0700, Stephen Hemminger wrote:
> > Bridge code calls ethtool to get speed. The conversion to using
> > only ethtool_ops broke the case of devices without ethtool_ops.
> > This is a new regression in 2.6.23.
> > 
> > Rearranged the switch to a logical order, and use gcc initializer.
> > 
> > Ps: speed should have been part of the network device structure from
> >     the start rather than burying it in ethtool.
> 
> Feel free to do the conversion ;-)  One of the things I like about the
> ethtool framework is it gives us a way to take stuff out of the drivers
> and put it in the midlayer without disturbing userspace.
> 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Acked-by: Matthew Wilcox <matthew@wil.cx>

Applied, thanks!
