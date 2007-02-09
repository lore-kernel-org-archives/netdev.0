From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] phy devices: use same arg types
Date: Fri, 09 Feb 2007 16:35:05 -0500
Message-ID: <45CCE909.1020306@garzik.org>
References: <20070205104420.4970ab1e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60528 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752538AbXBIVfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:35:07 -0500
In-Reply-To: <20070205104420.4970ab1e.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> sparse complains about differing types from prototype to
> definition, so change the u32 to phy_interface_t:
> 
> drivers/net/phy/phy_device.c:140:19: error: symbol 'phy_connect' redeclared with different type (originally declared at include/linux/phy.h:362) - incompatible argument 5 (different signedness)
> drivers/net/phy/phy_device.c:190:19: error: symbol 'phy_attach' redeclared with different type (originally declared at include/linux/phy.h:360) - incompatible argument 4 (different signedness)
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  drivers/net/phy/phy_device.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

applied


