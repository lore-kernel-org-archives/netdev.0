From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 2 Jun 2008 11:32:15 -0500
Message-ID: <20080602163215.GA3400@loki.buserror.net>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:60292 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbYFBQca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 12:32:30 -0400
Content-Disposition: inline
In-Reply-To: <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2008 at 11:25:14AM -0500, Kumar Gala wrote:
> The core provides functions like phy_read/phy_write.  Andy has recently 
> introduced board level workaround/fixups.  The problem is these 
> workarounds tend to use phy_read/phy_write and the board/platform code is 
> not built as modules.

So why not have those platforms select PHYLIB?

-Scott
