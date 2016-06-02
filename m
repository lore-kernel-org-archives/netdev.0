From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: FWD: [PATCH v2] Marvell phy: add fiber status check for some
 components
Date: Thu, 2 Jun 2016 16:56:36 +0200
Message-ID: <20160602145636.GA15379@lunn.ch>
References: <20160404132552.GH21828@lunn.ch>
 <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57643 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753276AbcFBO4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 10:56:40 -0400
Content-Disposition: inline
In-Reply-To: <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 11:23:22AM +0200, Charles-Antoine Couret wrote:
> 
> Hello,
> I'm sorry to repost that, but after one month, I need a answer to continue to imrpove my patch in the right direction. :)

Hi Charles-Aontine

Florian and I had a quick discussion. We think going with the Marvell
datasheet documentation is best.

Please just be careful to ensure the generic code does not try to
unconditionally read the registers, only the Marvell driver. I'm
talking about functions like genphy_config_advert(),
genphy_setup_forced(), genphy_restart_aneg() etc. We need to ensure we
are consistently using the correct page.

      Andrew
