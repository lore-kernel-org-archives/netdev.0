From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH v1 net-next 1/3] igb: set driver data for device entries
 that were missing
Date: Mon, 27 Apr 2015 11:42:29 -0400
Message-ID: <553E58E5.9000105@cumulusnetworks.com>
References: <1428707018-6405-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35310 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbbD0Pmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 11:42:37 -0400
Received: by qgej70 with SMTP id j70so51096502qge.2
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 08:42:36 -0700 (PDT)
In-Reply-To: <1428707018-6405-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/15 7:03 PM, Jonathan Toppins wrote:
> Three of the supported PCI device entries neglected to set driver data
> to "board_82575". This is not a problem until a new board type is
> defined, so avoid the potential problem all together.
>
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
>   drivers/net/ethernet/intel/igb/igb_main.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 8457d03..bb467bb 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -73,9 +73,9 @@ static const struct e1000_info *igb_info_tbl[] = {
>   };
>
>   static const struct pci_device_id igb_pci_tbl[] = {
> -	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_BACKPLANE_1GBPS) },
> -	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_SGMII) },
> -	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_BACKPLANE_2_5GBPS) },
> +	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_BACKPLANE_1GBPS), board_82575 },
> +	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_SGMII), board_82575 },
> +	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_BACKPLANE_2_5GBPS), board_82575 },
>   	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I211_COPPER), board_82575 },
>   	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I210_COPPER), board_82575 },
>   	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I210_FIBER), board_82575 },
>


Simple keepalive to make sure these have not been forgotten, the 
patchworks entries are still in "new" state.

http://patchwork.ozlabs.org/patch/460268/
http://patchwork.ozlabs.org/patch/460270/
http://patchwork.ozlabs.org/patch/460269/

Regards,
-Jon
