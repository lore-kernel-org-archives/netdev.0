From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 5/6] i40e: trivial cleanup
Date: Tue, 14 Jan 2014 18:22:14 +0400
Message-ID: <52D54816.7010403@cogentembedded.com>
References: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com> <1389689394-22369-6-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Aaron Brown <aaron.f.brown@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:45079 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbaANOWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 09:22:14 -0500
Received: by mail-lb0-f169.google.com with SMTP id q8so3543754lbi.28
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 06:22:13 -0800 (PST)
In-Reply-To: <1389689394-22369-6-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 14-01-2014 12:49, Aaron Brown wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>

> Remove some un-necessary parenthesis.

> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
> index 101ed41..d5d98fe 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
> @@ -485,8 +485,7 @@ i40e_status i40e_configure_lan_hmc(struct i40e_hw *hw,
>   		/* Make one big object, a single SD */
>   		info.count = 1;
>   		ret_code = i40e_create_lan_hmc_object(hw, &info);
> -		if ((ret_code) &&
> -		    (model == I40E_HMC_MODEL_DIRECT_PREFERRED))
> +		if (ret_code && (model == I40E_HMC_MODEL_DIRECT_PREFERRED))

    Parens around == are also unnecessary, if you're at it.

WBR, Sergei
