From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] mdio: Advertise pause (flow control) settings even
 if autoneg is off
Date: Tue, 13 Oct 2009 00:01:53 -0700 (PDT)
Message-ID: <20091013.000153.165586109.davem@davemloft.net>
References: <1255375577.2931.11.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52388
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933213AbZJMHB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:01:57 -0400
In-Reply-To: <1255375577.2931.11.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 12 Oct 2009 20:26:17 +0100

> Currently, if pause autoneg is off we do not set either pause
> advertising flag.  If autonegotiation of speed and duplex settings is
> enabled, there is no way for the link partner to distinguish this from
> our refusing to use pause frames.
> 
> We should instead set the advertising flags according to the forced
> mode so that the link partner can follow our lead.  This is consistent
> with the behaviour of other drivers.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next-2.6
