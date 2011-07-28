From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Wed, 27 Jul 2011 22:27:49 -0700 (PDT)
Message-ID: <20110727.222749.1654973220321763098.davem@davemloft.net>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	<20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab1G1F1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:27:51 -0400
In-Reply-To: <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Wed, 27 Jul 2011 15:17:59 -0700

> Add new set commands to configure the number of SR-IOV VFs, the
> number of VM queues and spoof checking on/off switch.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> ---
> 
>  include/linux/ethtool.h |   11 ++++++++++-
>  1 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index c6e427a..c4972ba 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -36,12 +36,14 @@ struct ethtool_cmd {
>  	__u8	mdio_support;
>  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
>  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> +	__u32	num_vfs;	/* Enable SR-IOV VFs */
> +	__u32	num_vmqs;	/* Set number of queues for VMDq */

You can't change the layout of this datastructure in this way without
breaking every ethtool binary out there.

You have to find another place to add these knobs.
