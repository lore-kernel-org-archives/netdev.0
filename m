From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/7] NetXen: Use multiple PCI functions
Date: Fri, 27 Apr 2007 20:13:35 -0400
Message-ID: <463291AF.9070901@garzik.org>
References: <200704201452.l3KEqbAd004477@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48200 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbXD1ANh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 20:13:37 -0400
In-Reply-To: <200704201452.l3KEqbAd004477@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Make driver use multiple PCI functions.
> This patch will make NetXen driver work with multiple PCI functions. This will
> make the usage of memory resources as well as interrupts more independent
> among different functions which results in better throughput. This change has
> been done after the multiport support is added in firmware.
> 
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> 
> ---
> 
>  drivers/net/netxen/netxen_nic.h          |  125 ++--
>  drivers/net/netxen/netxen_nic_ethtool.c  |   83 +--
>  drivers/net/netxen/netxen_nic_hdr.h      |    8 
>  drivers/net/netxen/netxen_nic_hw.c       |  221 ++++++--
>  drivers/net/netxen/netxen_nic_hw.h       |   18 
>  drivers/net/netxen/netxen_nic_init.c     |  117 +---
>  drivers/net/netxen/netxen_nic_isr.c      |   87 +--
>  drivers/net/netxen/netxen_nic_main.c     |  526 ++++++++++-----------
>  drivers/net/netxen/netxen_nic_niu.c      |   27 -
>  drivers/net/netxen/netxen_nic_phan_reg.h |  125 ----
>  10 files changed, 646 insertions(+), 691 deletions(-)

applied


