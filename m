From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] phylib: add RGMII-ID mode to the Marvell m88e1111 PHY
 to fix broken ucc_geth
Date: Sat, 09 Jun 2007 18:26:42 -0400
Message-ID: <466B2922.5080908@garzik.org>
References: <46653F17.8040304@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kim.phillips@freescale.com, netdev@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35185 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759267AbXFIW0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:26:45 -0400
In-Reply-To: <46653F17.8040304@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Li Yang wrote:
> From: Kim Phillips <kim.phillips@freescale.com>
> 
> Support for configuring RGMII-ID (RGMII with internal delay) mode on the
> 88e1111 and 88e1145.  Ucc_geth on MPC8360EMDS(the main user of ucc_geth)
> is broken after changed to use phylib.  It is fixed by adding this
> internal delay.
> 
> Also renamed 88e1111s -> 88e1111 (no references to an 88e1111s part were
> found), and fixed some whitespace.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
> Please push this to Linus before 2.6.22 rc phase ends.  The regression
> has caused serious breakage to ucc_geth driver.
> 
> drivers/net/phy/marvell.c |   62 
> +++++++++++++++++++++++++++++++++++++++------
> 1 files changed, 54 insertions(+), 8 deletions(-)

applied


