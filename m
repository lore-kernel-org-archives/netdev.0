From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v3 14/16] i40e: make a define from a large constant
Date: Fri, 20 Dec 2013 10:40:14 -0800
Message-ID: <1387564814.2353.60.camel@joe-AO722>
References: <1387563694-3166-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387563694-3166-15-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0223.hostedemail.com ([216.40.44.223]:56266 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751810Ab3LTSkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:40:17 -0500
In-Reply-To: <1387563694-3166-15-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 10:21 -0800, Jeff Kirsher wrote:
> Make a define used in the header file by both VF and PF drivers.
[]
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
[]
> @@ -66,6 +66,26 @@ enum i40e_dyn_idx_t {
[]
> +/* Supported RSS offloads */
> +#define I40E_DEFAULT_RSS_HENA ( \
> +	((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \

BIT_ULL

> +	((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \

etc...
