From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] phy layer: fix phy_mii_ioctl for autonegotiation
Date: Tue, 07 Aug 2007 17:34:42 -0400
Message-ID: <46B8E572.4040205@garzik.org>
References: <20070807101241.GA13994@moe.telargo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, macro@linux-mips.org
To: Domen Puncer <domen.puncer@telargo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60863 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937494AbXHGVep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 17:34:45 -0400
In-Reply-To: <20070807101241.GA13994@moe.telargo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Domen Puncer wrote:
> Fix a thinko (?) in setting phydev->autoneg.
> 
> 
> Signed-off-by: Domen Puncer <domen.puncer@telargo.com>
> 
> ---
> This fixes my "mii.h -> ethtool.h advertising #defines". I'm not sure
> why and how they're translated, but it does work now.
> Maybe they're just ignored, since mii-tool directly reads and writes
> MII registers.
> 
> 
>  drivers/net/phy/phy.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

applied


