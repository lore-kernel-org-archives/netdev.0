From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 09/17] fm10k: trivial fixup message style to include
 a colon
Date: Tue, 16 Jun 2015 17:16:18 +0300
Message-ID: <55802FB2.9080507@cogentembedded.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com> <1434462448-140563-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:32934 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754670AbbFPOQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 10:16:21 -0400
Received: by laka10 with SMTP id a10so12383046lak.0
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 07:16:20 -0700 (PDT)
In-Reply-To: <1434462448-140563-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/16/2015 4:47 PM, Jeff Kirsher wrote:

> From: Jacob Keller <jacob.e.keller@intel.com>

> Fix up error message style to include a colon.

> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> index 445014a..5269b16 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> @@ -1773,7 +1773,7 @@ static int fm10k_probe(struct pci_dev *pdev,
>   					   fm10k_driver_name);
>   	if (err) {
>   		dev_err(&pdev->dev,
> -			"pci_request_selected_regions failed 0x%x\n", err);
> +			"pci_request_selected_regions failed: 0x%x\n", err);

    I don't think printing error in hexadecimal makes much sense, so you might 
as well fix that format to "%d"...

WBR, Sergei
