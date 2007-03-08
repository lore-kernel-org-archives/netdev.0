From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: Re: [PATCH 1/3] NetXen: Make driver use multiple PCI functions
Date: Thu, 8 Mar 2007 18:17:56 +0530
Message-ID: <200703081817.57109.mithlesh@netxen.com>
References: <200703051253.l25CrF7b004967@dut39.unminc.com> <45ED4E81.6010408@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:39531 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbXCHMxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 07:53:11 -0500
In-Reply-To: <45ED4E81.6010408@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 March 2007 16:50, Jeff Garzik wrote:
> Linsys Contractor Mithlesh Thukral wrote:
> > NetXen: Make driver use multiple PCI functions.
> > This patch will make NetXen driver work with multiple PCI functions. This
> > will make the usage of memory resources as well as interrupts more
> > independent among different functions which results in better throughput.
> > This change has been done after the multiport capable firmware related
> > changes are already there in the NetXen's driver in Linux.
> >
> > Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> >
> > ---
> >
> >  drivers/net/netxen/netxen_nic.h          |  126 ++---
> >  drivers/net/netxen/netxen_nic_ethtool.c  |   80 +--
> >  drivers/net/netxen/netxen_nic_hdr.h      |    8
> >  drivers/net/netxen/netxen_nic_hw.c       |  213 ++++++--
> >  drivers/net/netxen/netxen_nic_hw.h       |   18
> >  drivers/net/netxen/netxen_nic_init.c     |  115 +---
> >  drivers/net/netxen/netxen_nic_isr.c      |   80 +--
> >  drivers/net/netxen/netxen_nic_main.c     |  523 ++++++++++-----------
> >  drivers/net/netxen/netxen_nic_niu.c      |   27 -
> >  drivers/net/netxen/netxen_nic_phan_reg.h |  125 -----
> >  10 files changed, 631 insertions(+), 684 deletions(-)
>
> applied 1-3 to #upstream (2.6.22)
hi Gurus,

Please bear with my poor understanding about the kernel development process. I 
have the following query:

1. We have sent these 3 patches which are have lined up for 2.6.22 kernel (as 
mentioned above).
2. The tree which is in netdev#upstream doesnt have these 3 above mentioned 
patches.
I need to send some patches now. My query is :

1. If i send the patches with respect to current netdev#upstream and if they 
are accepted, will the 3 patches which are applied for #upstream(2.6.22) 
not break (i mean not apply cleanly).
			OR
I should send the patches with respect to current netdev#upstream tree + above 
3 patches, so that these 3 patches apply cleanly when 2.6.22 development 
cycle begins.

Please advice me how to proceed on this.

Thanks,
Mithlesh Thukral
