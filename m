From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/17] sfc: Stop masking out XGMII faults over
 reconfigures
Date: Wed, 28 Apr 2010 12:45:35 -0700 (PDT)
Message-ID: <20100428.124535.59660095.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272482874.2549.20.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49105
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753590Ab0D1Tpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:45:31 -0400
In-Reply-To: <1272482874.2549.20.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:27:54 +0100

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> The aim of this code was to avoid a spurious XGMII fault over a MAC
> reconfigure. It's less relevant now that the PHY reconfigure isn't
> called from the MAC reconfigure.
> 
> After applying this patch, our link stress test passed 48 hours of
> testing without ever resetting the PHY.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
