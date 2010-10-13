From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow FEC driver to use fixed PHY support
Date: Wed, 13 Oct 2010 09:56:22 -0700 (PDT)
Message-ID: <20101013.095622.104069939.davem@davemloft.net>
References: <201010120703.o9C735Jd026818@goober.internal.moreton.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@uclinux.org
To: gerg@snapgear.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58404
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750846Ab0JMQ4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 12:56:00 -0400
In-Reply-To: <201010120703.o9C735Jd026818@goober.internal.moreton.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@snapgear.com>
Date: Tue, 12 Oct 2010 17:03:05 +1000

> At least one board using the FEC driver does not have a conventional
> PHY attached to it, it is directly connected to a somewhat simple
> ethernet switch (the board is the SnapGear/LITE, and the attached
> 4-port ethernet switch is a RealTek RTL8305). This switch does not
> present the usual register interface of a PHY, it presents nothing.
> So a PHY scan will find nothing - it finds ID's of 0 for each PHY
> on the attached MII bus.
> 
> After the FEC driver was changed to use phylib for supporting PHYs
> it no longer works on this particular board/switch setup.
> 
> Add code support to use a fixed phy if no PHY is found on the MII bus.
> This is based on the way the cpmac.c driver solved this same problem.
> 
> Signed-off-by: Greg Ungerer <gerg@uclinux.org>

Applied, thanks Greg.
