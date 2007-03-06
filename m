From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 19/19] network: add the missing phy_device speed information
 to phy_mii_ioctl
Date: Tue, 06 Mar 2007 06:21:20 -0500
Message-ID: <45ED4EB0.9010802@garzik.org>
References: <200703061042.l26Ag3q4019790@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shanlu@cs.uiuc.edu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53381 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965866AbXCFLVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:21:21 -0500
In-Reply-To: <200703061042.l26Ag3q4019790@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: "Shan Lu" <shanlu@cs.uiuc.edu>
> 
> Function `phy_mii_ioctl' returns physical device's information based on
> user requests.  When requested to return the basic mode control register
> information (BMCR), the original implementation only returns the physical
> device's duplex information and forgets to return speed information, which
> should not be because BMCR register is used to hold both duplex and speed
> information.
> 
> The patch checks the BMCR value against speed-related flags and fills the
> return structure's speed field accordingly.
> 
> Signed-off-by: Shan <shanlu@cs.uiuc.edu>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/phy/phy.c |    6 ++++++
>  1 file changed, 6 insertions(+)

applied


