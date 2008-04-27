From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation
Date: Sat, 26 Apr 2008 22:57:51 -0700 (PDT)
Message-ID: <20080426.225751.117819831.davem@davemloft.net>
References: <4812E73A.6060104@hartkopp.net>
	<20080426.021001.18044508.davem@davemloft.net>
	<20080426095923.GA22836@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, wg@grandegger.com,
	urs.thuermann@volkswagen.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de, oliver.hartkopp@volkswagen.de,
	xemul@openvz.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47499
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750926AbYD0F5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 01:57:51 -0400
In-Reply-To: <20080426095923.GA22836@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 26 Apr 2008 11:59:23 +0200

> Both copy_to_ and _from_user return the number of bytes, that failed to
> reach their destination, not the 0/-EXXX values.
> 
> Based on patch from Pavel Emelyanov <xemul@openvz.org>
> 
> Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
> Acked-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>

Applied, sans the local Makefile.build change in your tree,
thanks Sam. :-)
