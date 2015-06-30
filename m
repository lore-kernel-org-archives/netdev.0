From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] igb: Use ARRAY_SIZE instead fo
 sizeof(a)/sizeof(a[0])
Date: Mon, 29 Jun 2015 22:12:36 -0700
Message-ID: <1435641156.6661.1.camel@perches.com>
References: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pankaj.m@samsung.com
To: Maninder Singh <maninder1.s@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0020.hostedemail.com ([216.40.44.20]:48909 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750771AbbF3FMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 01:12:41 -0400
In-Reply-To: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-30 at 10:25 +0530, Maninder Singh wrote:
> Use ARRAY_SIZE instead fo sizeof(a)/sizeof(a[0])

I think all of these #defines should be removed instead
as they are all used only once.

> diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
[]
> @@ -37,8 +37,7 @@ static s32  igb_set_master_slave_mode(struct e1000_hw *hw);
>  static const u16 e1000_m88_cable_length_table[] = {
>  	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
>  #define M88E1000_CABLE_LENGTH_TABLE_SIZE \
> -	(sizeof(e1000_m88_cable_length_table) / \
> -	sizeof(e1000_m88_cable_length_table[0]))
> +	ARRAY_SIZE(e1000_m88_cable_length_table)
>  
>  static const u16 e1000_igp_2_cable_length_table[] = {
>  	0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
> @@ -50,8 +49,7 @@ static const u16 e1000_igp_2_cable_length_table[] = {
>  	83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
>  	104, 109, 114, 118, 121, 124};
>  #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
> -	(sizeof(e1000_igp_2_cable_length_table) / \
> -	 sizeof(e1000_igp_2_cable_length_table[0]))
> +	ARRAY_SIZE(e1000_igp_2_cable_length_table)
>  
>  /**
>   *  igb_check_reset_block - Check if PHY reset is blocked
