From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [net-next v2 09/71] smsc: Move the SMC (SMSC) drivers
Date: Mon, 1 Aug 2011 01:09:42 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FE464E9E5@MNEXMB2.qlogic.org>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1312082850-24914-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Nicolas Pitre <nico@fluxnic.net>,
	Donald Becker <becker@scyld.com>, Erik Stahlman <erik@vt.edu>,
	Dustin McIntire <dustin@sensoria.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	David Hinds <dahinds@users.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:15750
	"EHLO DB3EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753266Ab1HAGJ4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 02:09:56 -0400
In-Reply-To: <1312082850-24914-10-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Jeff Kirsher
> Sent: Sunday, July 31, 2011 8:56 AM
> Subject: [net-next v2 09/71] smsc: Move the SMC (SMSC) drivers
> 
> Moves the SMC (SMSC) drivers into drivers/net/ethernet/smsc/ and the
> necessary Kconfig and Makefile changes.  Also did some cleanup
> of NET_VENDOR_SMC Kconfig tag for the 8390 based drivers.
> 
> CC: Nicolas Pitre <nico@fluxnic.net>
> CC: Donald Becker <becker@scyld.com>
> CC: Erik Stahlman <erik@vt.edu>
> CC: Dustin McIntire <dustin@sensoria.com>
> CC: Steve Glendinning <steve.glendinning@smsc.com>
> CC: David Hinds <dahinds@users.sourceforge.net>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> -config NETXEN_NIC
> -	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
> -	depends on PCI
> -	select FW_LOADER
> -	help
> -	  This enables the support for NetXen's Gigabit Ethernet card.
> -
> 
> -obj-$(CONFIG_NETXEN_NIC) += netxen/
>  obj-$(CONFIG_NIU) += niu.o
>  obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
>  obj-$(CONFIG_SFC) += sfc/

I didn't get reason for above netxen_nic changes.

-Amit

