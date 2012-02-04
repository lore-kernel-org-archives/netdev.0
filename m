From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Remove macaddr option
Date: Sat, 04 Feb 2012 16:29:36 -0500 (EST)
Message-ID: <20120204.162936.1988486080455883986.davem@davemloft.net>
References: <1328289904-22401-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	shawn.guo@freescale.com
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab2BDVap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:30:45 -0500
In-Reply-To: <1328289904-22401-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Fri, 3 Feb 2012 15:25:04 -0200

> "macaddr" option allows users to pass the MAC address via kernel command line.
> 
> Feedbacks from Alan Cox and David Miller (http://www.spinics.net/lists/linux-usb/msg57821.html )
> mention that this is not a good idea, so remove it.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Whilst we can prevent new additions of such module options, you can't
just go and remove them from existing drivers without potentially
breaking things for people.

In this FEC case, the option was added more than a year ago.

I'm not applying this patch.
