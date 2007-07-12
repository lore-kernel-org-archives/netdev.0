From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK 03/04]: rtnl_link API simplification
Date: Wed, 11 Jul 2007 19:42:47 -0700 (PDT)
Message-ID: <20070711.194247.98556971.davem@davemloft.net>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
	<20070711173817.18369.57824.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com, xemul@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935308AbXGLCmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:42:25 -0400
In-Reply-To: <20070711173817.18369.57824.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 11 Jul 2007 19:38:17 +0200 (MEST)

> [RTNETLINK]: rtnl_link API simplification
> 
> All drivers need to unregister their devices in the module unload function.
> While doing so they must hold the rtnl and atomically unregister the
> rtnl_link ops as well. This makes the rtnl_link_unregister function that
> takes the rtnl itself completely useless.
> 
> Provide default newlink/dellink functions, make __rtnl_link_unregister and
> rtnl_link_unregister unregister all devices with matching rtnl_link_ops and
> change the existing users to take advantage of that.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
