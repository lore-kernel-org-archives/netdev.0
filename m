From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] sfc: QT2025C: Use hard reset only
Date: Wed, 26 Aug 2009 18:04:15 -0700 (PDT)
Message-ID: <20090826.180415.38484168.davem@davemloft.net>
References: <1251310639.27345.15.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53164
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754512AbZH0BEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 21:04:01 -0400
In-Reply-To: <1251310639.27345.15.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 26 Aug 2009 19:17:19 +0100

> At probe time, falcon_reset_hw() performs a hard reset of the PHY
> along with Falcon.  There is no need to perform a soft reset later,
> and any access to standard MDIO registers before the PHY firmware has
> booted can interrupt the boot process, making the port unusable.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
