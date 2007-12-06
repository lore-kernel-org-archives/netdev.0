From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][VLAN] Lost rtnl_unlock() in vlan_ioctl()
Date: Thu, 06 Dec 2007 06:01:51 -0800 (PST)
Message-ID: <20071206.060151.154858451.davem@davemloft.net>
References: <4757FE80.2080000@openvz.org>
	<4758003C.9080105@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60264
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752564AbXLFOBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:01:52 -0500
In-Reply-To: <4758003C.9080105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 06 Dec 2007 14:59:24 +0100

> Pavel Emelyanov wrote:
> > The SET_VLAN_NAME_TYPE_CMD command w/o CAP_NET_ADMIN capability
> > doesn't release the rtnl lock.
> 
> 
> Thanks Pavel. I somehow recall that we already fixed this
> one, but can't find the patch :) Dave, please apply.

I think we even added this bug to -stable, or something like
that, didn't we?  Yikes...
