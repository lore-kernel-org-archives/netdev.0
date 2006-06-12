From: Nathaniel Case <ncase@xes-inc.com>
Subject: Re: [PATCH 1/2] PHYLIB: Add get_link ethtool helper function
Date: Mon, 12 Jun 2006 11:12:04 -0500
Message-ID: <1150128725.30343.36.camel@localhost.localdomain>
References: <1149551292.10700.47.camel@localhost.localdomain>
	 <448C4131.3000504@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:44739 "EHLO xes-mad.com")
	by vger.kernel.org with ESMTP id S1752114AbWFLQMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 12:12:55 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <448C4131.3000504@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-06-11 at 12:13 -0400, Jeff Garzik wrote:
> > This adds a phy_ethtool_get_link() function along the same lines as
> > phy_ethtool_gset().  This provides drivers utilizing PHYLIB an
> > alternative to using ethtool_op_get_link().  This is more desirable
> > since the "Link detected" field in ethtool would actually reflect the
> > state of the PHY register.
> > 
[snip]
> NAK, needs an EXPORT

In that case, shouldn't we EXPORT phy_ethtool_sset() and
phy_ethtool_gset() in drivers/net/phy/phy.c as well?

- Nate Case <ncase@xes-inc.com>

