From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netdev: Remove redundant checks for CAP_NET_ADMIN
 in MDIO implementations
Date: Thu, 03 Sep 2009 20:10:20 -0700 (PDT)
Message-ID: <20090903.201020.234843615.davem@davemloft.net>
References: <1252010383.2781.17.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932536AbZIDDKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:10:05 -0400
In-Reply-To: <1252010383.2781.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 03 Sep 2009 21:39:43 +0100

> dev_ioctl() already checks capable(CAP_NET_ADMIN) before calling the
> driver's implementation of MDIO ioctls.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Man, it wasn't fun validating the cases where you removed the
check function-wide for a ->ndo_dev_ioctl() implementation. :-/

Applied...
