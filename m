From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] net: vxge: Remove unused device pointer
Date: Mon, 10 Feb 2014 09:01:04 +0900
Message-ID: <003201cf25f3$3110d0e0$933272a0$%han@samsung.com>
References: <20140209001617.1d1543d4@spike>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	'Patrick McHardy' <kaber@trash.net>,
	'Masanari Iida' <standby24x7@gmail.com>,
	'John Stultz' <john.stultz@linaro.org>,
	'dingtianhong' <dingtianhong@huawei.com>,
	'Ben Hutchings' <bhutchings@solarflare.com>,
	'stephen hemminger' <stephen@networkplumber.org>,
	'Tom Herbert' <therbert@google.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Christian Engelmayer' <cengelma@gmx.at>,
	'Jon Mason' <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:62035 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbaBJABJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 19:01:09 -0500
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N0R00MB06PTMY00@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 10 Feb 2014 09:01:05 +0900 (KST)
In-reply-to: <20140209001617.1d1543d4@spike>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, February 09, 2014 8:16 AM, Christian Engelmayer wrote:
> 
> Remove occurrences of unused struct __vxge_hw_device pointer in functions
> vxge_learn_mac() and vxge_rem_isr().
> 
> Detected by Coverity: CID 139839, CID 139842.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Reviewed-by: Jingoo Han <jg1.han@samsung.com>

Best regards,
Jingoo Han

> ---
>  drivers/net/ethernet/neterion/vxge/vxge-main.c | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-
> main.c
> index 1ded50ca..e46e869 100644
> --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> @@ -726,9 +726,6 @@ static int vxge_learn_mac(struct vxgedev *vdev, u8 *mac_header)
>  	int vpath_idx = 0;
>  	enum vxge_hw_status status = VXGE_HW_OK;
>  	struct vxge_vpath *vpath = NULL;
> -	struct __vxge_hw_device *hldev;
> -
> -	hldev = pci_get_drvdata(vdev->pdev);
> 
>  	mac_address = (u8 *)&mac_addr;
>  	memcpy(mac_address, mac_header, ETH_ALEN);
> @@ -2443,9 +2440,6 @@ static void vxge_rem_msix_isr(struct vxgedev *vdev)
> 
>  static void vxge_rem_isr(struct vxgedev *vdev)
>  {
> -	struct __vxge_hw_device *hldev;
> -	hldev = pci_get_drvdata(vdev->pdev);
> -
>  #ifdef CONFIG_PCI_MSI
>  	if (vdev->config.intr_type == MSI_X) {
>  		vxge_rem_msix_isr(vdev);
> --
> 1.8.3.2
