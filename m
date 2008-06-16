From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [patch 6/9] DM9000: Allow the use of the NSR register to get
	link status.
Date: Mon, 16 Jun 2008 13:51:20 +0100
Message-ID: <20080616125120.GA26276@fluff.org.uk>
References: <20080615232653.642837440@fluff.org.uk> <20080615232815.765902209@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:64737 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752739AbYFPMvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 08:51:22 -0400
Content-Disposition: inline
In-Reply-To: <20080615232815.765902209@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 12:26:59AM +0100, Ben Dooks wrote:
> The DM9000's internal PHY reports a copy of the link status
> in the NSR register of the chip. Reading the status when
> polling for link status is faster as it eliminates the need
> to sleep, but does not print as much information.
> 
> Add an platform flag to force this behaviour, and a Kconfig
> option to allow it to be forced to the faster method always.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Argh, this didn't get refreshed before emailing the quilt, will
fix and re-send with the blackfin updates

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
