From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] NetXen: Fix link status messages
Date: Tue, 12 Jun 2007 22:28:36 -0400
Message-ID: <466F5654.4010604@garzik.org>
References: <200706111030.l5BAUwep005818@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60216 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682AbXFMC2j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 22:28:39 -0400
In-Reply-To: <200706111030.l5BAUwep005818@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Fix incorrect link status even with switch turned OFF.
> NetXen driver failed to accurately indicate when a link is up or down. 
> This was encountered during failover testing, when the first port 
> indicated that the link was up even when the 10G switch it was assigned
> to in the Bladecenter was turned off completely. 
> 
> Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
> 
>  drivers/net/netxen/netxen_nic.h      |    1 +
>  drivers/net/netxen/netxen_nic_init.c |   21 +++++++++++++--------
>  drivers/net/netxen/netxen_nic_isr.c  |   24 ++++++++++++++++++++++++
>  3 files changed, 38 insertions(+), 8 deletions(-)

applied to #upstream-fixes


