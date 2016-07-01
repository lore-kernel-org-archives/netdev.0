From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 0/2] net: ethernet: Add support for gmii2rgmii
 converter
Date: Fri, 1 Jul 2016 17:13:04 +0200
Message-ID: <20160701151304.GE6804@lunn.ch>
References: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: appanad@xilinx.com, michal.simek@xilinx.com,
	nicolas.ferre@atmel.com, punnaia@xilinx.com, anirudh@xilinx.com,
	harinik@xilinx.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34255 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199AbcGAPNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2016 11:13:21 -0400
Content-Disposition: inline
In-Reply-To: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2016 at 11:50:10AM +0530, Kedareswara rao Appana wrote:
> This patch series does the following
> ---> Add support for gmii2rgmii converter.

How generic is this gmii2rgmii IP block? Could it be used with any
GMII and RGMII device?

Should it be placed in drivers/net/phy, so making it easier to reuse?

Also, Russell Kings phylink might be a more natural structure for
this. It is hard to know when those patches will land, but it might be
worth looking at.

       Andrew
