From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [RFC 1/2] net: Add support to configure SR-IOV VF minimum and
 maximum Tx rate through ip tool.
Date: Wed, 5 Mar 2014 10:33:13 +0100
Message-ID: <20140305093312.GA27992@unicorn.suse.cz>
References: <1394004816-23436-1-git-send-email-sucheta.chakraborty@qlogic.com>
 <1394004816-23436-2-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept-HSGLinuxNICDev@qlogic.com
To: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55917 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbaCEJdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 04:33:15 -0500
Content-Disposition: inline
In-Reply-To: <1394004816-23436-2-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2014 at 02:33:35AM -0500, Sucheta Chakraborty wrote:
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 16410b6..fce6437 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -398,7 +398,8 @@ enum {
>  	IFLA_VF_UNSPEC,
>  	IFLA_VF_MAC,		/* Hardware queue specific attributes */
>  	IFLA_VF_VLAN,
> -	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
> +	IFLA_VF_TX_RATE,	/* Max TX Bandwidth Allocation */
> +	IFLA_VF_RATE,		/* Min and Max TX Bandwidth Allocation */
>  	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
>  	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
>  	__IFLA_VF_MAX,

This would change the values of IFLA_VF_SPOOFCHK and IFLA_VF_LINK_STATE,
making "old" (including current) iproute2 incompatible with future
kernels and vice versa.

                                                         Michal Kubecek
