From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 07/16] i40e: Define and use i40e_is_vf macro
Date: Sat, 06 Dec 2014 05:18:59 -0800
Message-ID: <1417871939.31745.13.camel@perches.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1417870933-17248-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0094.hostedemail.com ([216.40.44.94]:57796 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751761AbaLFNTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 08:19:04 -0500
In-Reply-To: <1417870933-17248-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-12-06 at 05:02 -0800, Jeff Kirsher wrote:
> From: Anjali Singhai Jain <anjali.singhai@intel.com>
> 
> This patch is useful for future expansion when new VF MAC types get
> added. It helps with cleaning up VF driver flow.
[]
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
[]
> +#define i40e_is_vf(_hw)	((_hw)->mac.type == I40E_MAC_VF)
[]
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
[]
> +#define i40e_is_vf(_hw)	((_hw)->mac.type == I40E_MAC_VF)

These are probably better as static inline
