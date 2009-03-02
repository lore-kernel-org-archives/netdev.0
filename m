From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH]: ixgbe: Fix some compiler warnings.
Date: Sun, 1 Mar 2009 22:40:12 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0903012239150.29160@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090301.203351.249644255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:58336 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169AbZCBGkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 01:40:23 -0500
In-Reply-To: <20090301.203351.249644255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 1 Mar 2009, David Miller wrote:

> @@ -661,7 +661,7 @@ static s32 ixgbe_poll_eeprom_eerd_done(struct ixgbe_hw *hw)
>  static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
>  {
>         s32 status = 0;
> -       u32 eec;
> +       u32 eec = 0;
>         u32 i;
> 
>         if (ixgbe_acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) != 0)
> diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
> index 1467d56..adcbac4 100644
> --- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
> +++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
> @@ -457,8 +457,6 @@ s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
>  s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
>                                struct ixgbe_dcb_config *dcb_config)
>  {
> -       u32  pap = 0;
> -

Thanks Dave.  We removed the code that used pap since it was used only for 
silicon validation, but we forgot to pull the variable.

Thanks for cleaning these up!

Cheers,
-PJ Waskiewicz
