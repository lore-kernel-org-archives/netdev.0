From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [PATCH net-next] ixgbe: fix ixgbe_check_reset_blocked()
 declaration
Date: Mon, 10 Mar 2014 18:26:56 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664685D8692D@ORSMSX110.amr.corp.intel.com>
References: <1394414342-2482-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jean Sacren <sakiwit@gmail.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50392 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbaCJS07 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 14:26:59 -0400
In-Reply-To: <1394414342-2482-1-git-send-email-sakiwit@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jean Sacren [mailto:sakiwit@gmail.com]
> Sent: Sunday, March 09, 2014 6:19 PM
> To: Brown, Aaron F
> Cc: netdev@vger.kernel.org; Skidmore, Donald C
> Subject: [PATCH net-next] ixgbe: fix ixgbe_check_reset_blocked()
> declaration
> 
> The commit c97506ab0e22 ("ixgbe: Add check for FW veto bit") introduced
> the new function ixgbe_check_reset_blocked() with a minor issue in
> declaration. Fix the declaration by changing the type specifier to bool as the
> definition returns a boolean value.
> Additionally all ixgbe_check_reset_blocked() callers are expected to return a
> boolean value.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 2 +-
> drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> index d2caae4750e0..05e083c99000 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> @@ -106,7 +106,7 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw
> *hw)
>   * have this bit just return false since the link can not be blocked
>   * via this method.
>   **/
> -s32 ixgbe_check_reset_blocked(struct ixgbe_hw *hw)
> +bool ixgbe_check_reset_blocked(struct ixgbe_hw *hw)
>  {
>  	u32 mmngc;
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
> index b4d4323666b8..52a9254c34bc 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
> @@ -131,7 +131,7 @@ s32 ixgbe_setup_phy_link_speed_generic(struct
> ixgbe_hw *hw,
>  s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
>                                                 ixgbe_link_speed *speed,
>                                                 bool *autoneg);
> -s32 ixgbe_check_reset_blocked(struct ixgbe_hw *hw);
> +bool ixgbe_check_reset_blocked(struct ixgbe_hw *hw);
> 
>  /* PHY specific */
>  s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw,

This was an over look on my part. Thanks for the patch. :)

Acked-By: Don Skidmore <donald.c.skidmore@intel.com>
