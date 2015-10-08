From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 07/18] i40e: make i40e_init_pf_fcoe to void
Date: Thu, 8 Oct 2015 21:53:02 +0300
Message-ID: <5616BB8E.4090903@cogentembedded.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1444258032-41476-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36778 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181AbbJHSxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 14:53:07 -0400
Received: by lbcao8 with SMTP id ao8so58024779lbc.3
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 11:53:04 -0700 (PDT)
In-Reply-To: <1444258032-41476-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/08/2015 01:47 AM, Jeff Kirsher wrote:

> From: Shannon Nelson <shannon.nelson@intel.com>
>
> i40e_init_pf_fcoe() didn't return anything except 0, it prints enough
> error info already, and no driver logic depends on the return value,
> so this can be void.
>
> Change-ID: Ie6afad849857d87a7064c42c3cce14c74c2f29d8
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
> index 5ea75dd..2398d9b 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
[...]
> @@ -326,7 +324,7 @@ int i40e_init_pf_fcoe(struct i40e_pf *pf)
>   	wr32(hw, I40E_GLFCOE_RCTL, val);
>
>   	dev_info(&pf->pdev->dev, "FCoE is supported.\n");
> -	return 0;
> +	return;

    Not needed at all.

>   }
>
>   /**
[...]

MBR, Sergei
