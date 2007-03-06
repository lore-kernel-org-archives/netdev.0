From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] NetXen: Make driver use multiple PCI functions
Date: Tue, 06 Mar 2007 06:20:33 -0500
Message-ID: <45ED4E81.6010408@garzik.org>
References: <200703051253.l25CrF7b004967@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53348 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934080AbXCFLUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:20:35 -0500
In-Reply-To: <200703051253.l25CrF7b004967@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Mithlesh Thukral wrote:
> NetXen: Make driver use multiple PCI functions.
> This patch will make NetXen driver work with multiple PCI functions. This will
> make the usage of memory resources as well as interrupts more independent
> among different functions which results in better throughput. This change has
> been done after the multiport capable firmware related changes are already
> there in the NetXen's driver in Linux.
> 
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> 
> ---
> 
>  drivers/net/netxen/netxen_nic.h          |  126 ++---
>  drivers/net/netxen/netxen_nic_ethtool.c  |   80 +--
>  drivers/net/netxen/netxen_nic_hdr.h      |    8 
>  drivers/net/netxen/netxen_nic_hw.c       |  213 ++++++--
>  drivers/net/netxen/netxen_nic_hw.h       |   18 
>  drivers/net/netxen/netxen_nic_init.c     |  115 +---
>  drivers/net/netxen/netxen_nic_isr.c      |   80 +--
>  drivers/net/netxen/netxen_nic_main.c     |  523 ++++++++++-----------
>  drivers/net/netxen/netxen_nic_niu.c      |   27 -
>  drivers/net/netxen/netxen_nic_phan_reg.h |  125 -----
>  10 files changed, 631 insertions(+), 684 deletions(-)

applied 1-3 to #upstream (2.6.22)


