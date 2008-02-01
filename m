From: David Miller <davem@davemloft.net>
Subject: Re: [drivers/net/bnx2.c] ADVERTISE_1000XPSE_ASYM
Date: Thu, 31 Jan 2008 17:07:39 -0800 (PST)
Message-ID: <20080131.170739.246050174.davem@davemloft.net>
References: <47A084B0.1000301@tiscali.nl>
	<1201719070.7190.4.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 12o3l@tiscali.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751575AbYBABHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 20:07:18 -0500
In-Reply-To: <1201719070.7190.4.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 30 Jan 2008 10:51:10 -0800

> [BNX2]: Fix ASYM PAUSE advertisement for remote PHY.
> 
> We were checking for the ASYM_PAUSE bit for 1000Base-X twice instead
> checking for both the 1000Base-X bit and the 10/100/1000Base-T bit.
> The purpose of the logic is to tell the firmware that ASYM_PAUSE is
> set on either the Serdes or Copper interface.
> 
> Problem was discovered by Roel Kluin <12o3l@tiscali.nl>
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
