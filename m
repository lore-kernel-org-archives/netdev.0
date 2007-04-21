From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] [IrDA] IrDA monitor mode
Date: Fri, 20 Apr 2007 22:11:43 -0700 (PDT)
Message-ID: <20070420.221143.132446079.davem@davemloft.net>
References: <20070418213202.214829666@sortiz.org>
	<20070418214751.455457680@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41465
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932282AbXDUFLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 01:11:40 -0400
In-Reply-To: <20070418214751.455457680@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: samuel@sortiz.org
Date: Thu, 19 Apr 2007 00:32:07 +0300

> Through a protocol specific ioctl, one can disable IrDA TX in order to
> monitor an IrDA link.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

I'd really rather see IRDA use netlink instead of these
wonky ioctls, but whatever, if you want to put this dirty
into your stack and you're the maintainer I can't really
stop you :-)

Applied to net-2.6.22, thanks.
