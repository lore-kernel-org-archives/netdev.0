From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 13/13] i40e/i40evf: Convert macro to static inline
Date: Tue, 09 Dec 2014 22:06:19 +0300
Message-ID: <5487482B.1030609@cogentembedded.com>
References: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com> <1418124170-7495-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:55020 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbaLITGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:06:24 -0500
Received: by mail-la0-f47.google.com with SMTP id hz20so1073898lab.20
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 11:06:22 -0800 (PST)
In-Reply-To: <1418124170-7495-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/09/2014 02:22 PM, Jeff Kirsher wrote:

> Inline functions are preferred over macros when they can be used
> interchangeably.

> Reported-by: Joe Perches <joe@perches.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_type.h   | 5 ++++-
>   drivers/net/ethernet/intel/i40evf/i40e_type.h | 5 ++++-
>   2 files changed, 8 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
> index 844421f..618cce2 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_type.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
> @@ -481,7 +481,10 @@ struct i40e_hw {
>   	u32 debug_mask;
>   };
>
> -#define i40e_is_vf(_hw)	((_hw)->mac.type == I40E_MAC_VF)
> +static inline bool i40e_is_vf(struct i40e_hw *hw)
> +{
> +	return (hw->mac.type == I40E_MAC_VF);

    Parens not needed.

[...]
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
> index d8175cd..6b6fcf6 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
> @@ -475,7 +475,10 @@ struct i40e_hw {
>   	u32 debug_mask;
>   };
>
> -#define i40e_is_vf(_hw)	((_hw)->mac.type == I40E_MAC_VF)
> +static inline bool i40e_is_vf(struct i40e_hw *hw)
> +{
> +	return (hw->mac.type == I40E_MAC_VF);

    Likewise.

[...]

WBR, Sergei
