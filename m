From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] NetXen: Use pci_register_driver() instead of pci_module_init()
 in init_module
Date: Tue, 23 Jan 2007 01:04:32 -0500
Message-ID: <45B5A570.5080408@garzik.org>
References: <200701221452.l0MEqrdx005015@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com, linuxram@us.ibm.com,
	netxenproj@linsyssoft.com, ricknu-0@student.ltu.se, rob@netxen.com,
	sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45555 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933033AbXAWGEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 01:04:37 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <200701221452.l0MEqrdx005015@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale wrote:
> I am extremely sorry for sending this patch with wrong subject line before this.
> Now i am resending the patch with correct line.
> 
> Thanks,
> --Amit

Please include comments such as the above quoted /below/ the "---" 
terminator.

The git merge scripts copy everything preceding "---" directly into the 
kernel changelog.  Everything following "---", except the patch itself, 
is ignored by the automated tools.

	Jeff




> This will use pci_register_driver() instead of pci_module_init().
> 
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>
> Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
> 
> ---
>  netxen_nic.h      |    2 +-
>  netxen_nic_main.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
> index 663fa2f..59324b1 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -63,7 +63,7 @@ #include <asm/pgtable.h>
>  
>  #include "netxen_nic_hw.h"
>  
> -#define NETXEN_NIC_BUILD_NO     "1"
> +#define NETXEN_NIC_BUILD_NO     "2"

Please remove NETXEN_NIC_BUILD_NO, it is incompatible with Linux kernel 
development.  People who modify the kernel API, and then update drivers 
for that new API, will likely not bother with updating this variable, 
making it largely useless in practice.

	Jeff




