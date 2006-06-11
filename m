From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] PHYLIB: Add get_link ethtool helper function
Date: Sun, 11 Jun 2006 12:13:37 -0400
Message-ID: <448C4131.3000504@garzik.org>
References: <1149551292.10700.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50911 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932124AbWFKQNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 12:13:40 -0400
To: Nathaniel Case <ncase@xes-inc.com>
In-Reply-To: <1149551292.10700.47.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nathaniel Case wrote:
> This adds a phy_ethtool_get_link() function along the same lines as
> phy_ethtool_gset().  This provides drivers utilizing PHYLIB an
> alternative to using ethtool_op_get_link().  This is more desirable
> since the "Link detected" field in ethtool would actually reflect the
> state of the PHY register.
> 
> Patch depends on previous patch (0/2).
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>

NAK, needs an EXPORT


