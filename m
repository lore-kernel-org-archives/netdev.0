From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 1/6] SMSC LAN911x and LAN921x vendor driver
Date: Fri, 14 Nov 2008 15:57:24 +0000
Message-ID: <OF90AC0DB8.3F662474-ON80257501.005761EF-80257501.0057AD0D@smsc.com>
References: <491287E8.70704@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir.Balban@arm.com, bgat@billgatliff.com,
	catalin.marinas@arm.com, dustin@sensoria.com,
	g.liakhovetski@gmx.de, ian.saturley@smsc.com,
	Peter Korsgaard <jacmet@sunsite.dk>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1480 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751560AbYKNP6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 10:58:32 -0500
In-Reply-To: <491287E8.70704@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Could you please also apply #2 (smsc911x: add dynamic bus configuration), 
as all the platform-specific patches depend on it.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com



Jeff Garzik <jeff@garzik.org> wrote on 06/11/2008 06:00:08:

> Steve Glendinning wrote:
> > Attached is a driver for SMSC's LAN911x and LAN921x families of 
embedded
> > ethernet controllers.
> > 
> > There is an existing smc911x driver in the tree; this is intended to
> > replace it.  Dustin McIntire (the author of the smc911x driver) has
> > expressed his support for switching to this driver.
> > 
> > This driver contains workarounds for all known hardware issues, and 
has
> > been tested on all flavours of the chip on multiple architectures.
> > 
> > This driver now uses phylib, so this patch also adds support for the
> > device's internal phy
> > 
> > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> > Signed-off-by: Bahadir Balban <Bahadir.Balban@arm.com>
> > Signed-off-by: Dustin Mcintire <dustin@sensoria.com>
> > Signed-off-by: Bill Gatliff <bgat@billgatliff.com>
> > ---
> >  MAINTAINERS              |    6 +
> >  drivers/net/Kconfig      |   14 +
> >  drivers/net/Makefile     |    1 +
> >  drivers/net/phy/smsc.c   |   28 +
> >  drivers/net/smsc911x.c   | 2091 
> ++++++++++++++++++++++++++++++++++++++++++++++
> >  drivers/net/smsc911x.h   |  394 +++++++++
> >  include/linux/smsc911x.h |   42 +
> >  7 files changed, 2576 insertions(+), 0 deletions(-)
> >  create mode 100644 drivers/net/smsc911x.c
> >  create mode 100644 drivers/net/smsc911x.h
> >  create mode 100644 include/linux/smsc911x.h
> 
> applied patch #1
> 
> ACK patches 2-6
> 
> 

