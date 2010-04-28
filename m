From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/17] sfc: Handle serious errors in exactly one
 interrupt handler
Date: Wed, 28 Apr 2010 12:45:28 -0700 (PDT)
Message-ID: <20100428.124528.39162118.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272482856.2549.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49100
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756864Ab0D1TpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:45:24 -0400
In-Reply-To: <1272482856.2549.19.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:27:36 +0100

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> 'Fatal' errors set an interrupt flag associated with a specific event
> queue; only read the syndrome vector if we see that queue's flag set
> (legacy interrupts) or in the interrupt handler for that queue (MSI).
> 
> Do not ignore an interrupt if the fatal error flag is set but specific
> error flags are all zero.  Even if we don't schedule a reset, we must
> respect the queue mask and rearm the appropriate event queues.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
