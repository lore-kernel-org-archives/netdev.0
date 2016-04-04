From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] Marvell phy: add fiber status check for some components
Date: Mon, 4 Apr 2016 14:22:19 +0200
Message-ID: <20160404122219.GD21828@lunn.ch>
References: <56FE9B5C.6030509@nexvision.fr>
 <56FEA2EC.2030303@nexvision.fr>
 <20160401170838.GA21633@lunn.ch>
 <570229B6.4090805@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45758 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378AbcDDMWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 08:22:21 -0400
Content-Disposition: inline
In-Reply-To: <570229B6.4090805@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 10:45:42AM +0200, Charles-Antoine Couret wrote:
> Hi,
> 
> > Shouldn't you return to page 0, i.e. MII_M1111_COPPER, under all
> > conditions?
> 
> I return marvell_read_status() which returns 0 if it hasn't error during the process.
> In case of right conditions, my function returns 0 for COPPER part (and FIBER part too).
> 
> It doesn't change the value returned and behavior.

Hi Charles

Please read my email again. I'm talking about the phy page, not the
function return value.

	 Andrew
