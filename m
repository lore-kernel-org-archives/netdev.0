From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC PATCH 12/12] ixgbevf: Kconfig, Makefile and Documentation
Date: Tue, 8 Dec 2009 14:41:36 -0800
Message-ID: <20091208144136.dff6ce84.randy.dunlap@oracle.com>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
	<20091208221652.28373.22254.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:27034 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619AbZLHWlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 17:41:51 -0500
In-Reply-To: <20091208221652.28373.22254.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Dec 2009 14:16:53 -0800 Jeff Kirsher wrote:

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Modifications for the Kconfig and network device Makefile to add the ixgbevf
> driver module to the kernel and documentation.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  Documentation/networking/ixgbevf.txt |   94 ++++++++++++++++++++++++++++++++++
>  drivers/net/Kconfig                  |   21 ++++++++
>  drivers/net/Makefile                 |    1 
>  3 files changed, 116 insertions(+), 0 deletions(-)
>  create mode 100755 Documentation/networking/ixgbevf.txt
> 
> diff --git a/Documentation/networking/ixgbevf.txt b/Documentation/networking/ixgbevf.txt
> new file mode 100755
> index 0000000..4981426
> --- /dev/null
> +++ b/Documentation/networking/ixgbevf.txt

> +The ixgbevf driver supports 82599-based virtual function devices that can only
> +be activated on kernels with CONFIG_PCI_IOV enabled.
> +
> +The guest OS loading the ixgbevf driver must support MSI-X interrupts.

Hi,

Could the Kconfig language express some of these requirements, or
am I confused between the host and the guest OS?


> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 0bbd5ae..a484415 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2614,6 +2614,27 @@ config IXGBE_DCB
>  
>  	  If unsure, say N.
>  
> +config IXGBEVF
> +       tristate "Intel(R) 82599 Virtual Function Ethernet support"
> +       depends on PCI

	depends on PCI_IOV && PCI_MSI
??


> +       ---help---
> +         This driver supports Intel(R) 82599 virtual functions.  For more
> +         information on how to identify your adapter, go to the Adapter &
> +         Driver ID Guide at:
> +
> +         <http://support.intel.com/support/network/adapter/pro100/21397.htm>
> +
> +         For general information and support, go to the Intel support
> +         website at:
> +
> +         <http://support.intel.com>
> +
> +         More specific information on configuring the driver is in
> +         <file:Documentation/networking/ixgbe.txt>.
> +
> +         To compile this driver as a module, choose M here. The module
> +         will be called ixgbevf.
> +


---
~Randy
