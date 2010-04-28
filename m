From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/17] sfc: Ignore parity errors in the other port's
 SRAM
Date: Wed, 28 Apr 2010 12:45:15 -0700 (PDT)
Message-ID: <20100428.124515.112615165.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49092
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753583Ab0D1TpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:45:10 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:25:22 +0100

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Siena has a separate SRAM bank for each port.  On single-port boards
> these can be merged together, so each port has an interrupt flag for
> parity errors in the other port's SRAM.  Currently we do not enable
> such merging and should mask this interrupt source.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
