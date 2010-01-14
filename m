From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sfc: Fix conditions for MDIO self-test
Date: Wed, 13 Jan 2010 17:15:58 -0800 (PST)
Message-ID: <20100113.171558.254401022.davem@davemloft.net>
References: <1263416353.2797.22.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750862Ab0ANBPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 20:15:48 -0500
In-Reply-To: <1263416353.2797.22.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 13 Jan 2010 20:59:13 +0000

> The MDIO self-test should not be run on boards without an MDIO PHY,
> such as SFN5122F-R3 and later revisions.  It should also not try to
> address a specific MMD in an MDIO clause 22 PHY.  Check the
> mode_support field to decide which mode to use, if any.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
