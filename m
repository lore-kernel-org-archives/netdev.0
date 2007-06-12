From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] NetXen: Add correct routines to setup multicast address
Date: Tue, 12 Jun 2007 18:58:24 -0400
Message-ID: <466F2510.6080504@garzik.org>
References: <200706111031.l5BAVgKn005837@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59160 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509AbXFLW61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 18:58:27 -0400
In-Reply-To: <200706111031.l5BAVgKn005837@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Add multi cast filter code
> This patch adds multi cast filter code to NetXen NIC driver.
> It also adds capabilities to setup the multicast address in hardware
> from the host side.
> 
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
> 
>  drivers/net/netxen/netxen_nic.h     |   24 ++++
>  drivers/net/netxen/netxen_nic_hdr.h |    3 
>  drivers/net/netxen/netxen_nic_hw.c  |  132 +++++++++++++++++++++++++-
>  3 files changed, 156 insertions(+), 3 deletions(-)

Michael seems to keep finding endian bugs in this code...


