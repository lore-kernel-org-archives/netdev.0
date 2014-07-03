From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 03/14] i40e/i40evf: Force a shifted '1' to be unsigned
Date: Wed, 02 Jul 2014 20:34:10 -0700
Message-ID: <1404358450.14741.20.camel@joe-AO725>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1404355233-30123-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0116.hostedemail.com ([216.40.44.116]:41879 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752190AbaGCDeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 23:34:14 -0400
In-Reply-To: <1404355233-30123-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-02 at 19:40 -0700, Jeff Kirsher wrote:
> Force a shifted '1' to be unsiged to avoid shifting a signed int

It doesn't make a difference, but it's up to you.

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.h b/drivers/net/ethernet/intel/i40e/i40e_hmc.h
[]
> @@ -127,7 +127,7 @@ struct i40e_hmc_info {
>  		((((type) == I40E_SD_TYPE_PAGED) ? 0 : 1) <<		\
>  		I40E_PFHMC_SDDATALOW_PMSDTYPE_SHIFT) |			\
>  		(1 << I40E_PFHMC_SDDATALOW_PMSDVALID_SHIFT);		\
> -	val3 = (sd_index) | (1 << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
> +	val3 = (sd_index) | (1u << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
>  	wr32((hw), I40E_PFHMC_SDDATAHIGH, val1);			\
>  	wr32((hw), I40E_PFHMC_SDDATALOW, val2);				\
>  	wr32((hw), I40E_PFHMC_SDCMD, val3);				\
