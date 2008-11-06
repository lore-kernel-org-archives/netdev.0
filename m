From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] SMSC LAN911x and LAN921x vendor driver
Date: Thu, 06 Nov 2008 01:00:08 -0500
Message-ID: <491287E8.70704@garzik.org>
References: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com> <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, catalin.marinas@arm.com,
	Bahadir.Balban@arm.com, dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50882 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbYKFGAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 01:00:14 -0500
In-Reply-To: <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning wrote:
> Attached is a driver for SMSC's LAN911x and LAN921x families of embedded
> ethernet controllers.
> 
> There is an existing smc911x driver in the tree; this is intended to
> replace it.  Dustin McIntire (the author of the smc911x driver) has
> expressed his support for switching to this driver.
> 
> This driver contains workarounds for all known hardware issues, and has
> been tested on all flavours of the chip on multiple architectures.
> 
> This driver now uses phylib, so this patch also adds support for the
> device's internal phy
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> Signed-off-by: Bahadir Balban <Bahadir.Balban@arm.com>
> Signed-off-by: Dustin Mcintire <dustin@sensoria.com>
> Signed-off-by: Bill Gatliff <bgat@billgatliff.com>
> ---
>  MAINTAINERS              |    6 +
>  drivers/net/Kconfig      |   14 +
>  drivers/net/Makefile     |    1 +
>  drivers/net/phy/smsc.c   |   28 +
>  drivers/net/smsc911x.c   | 2091 ++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/smsc911x.h   |  394 +++++++++
>  include/linux/smsc911x.h |   42 +
>  7 files changed, 2576 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/smsc911x.c
>  create mode 100644 drivers/net/smsc911x.h
>  create mode 100644 include/linux/smsc911x.h

applied patch #1

ACK patches 2-6


