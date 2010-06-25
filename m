From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH ethtool 4/5] ethtool: Implement named message type flags
Date: Fri, 25 Jun 2010 13:11:21 -0400
Message-ID: <4C24E339.6000606@pobox.com>
References: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com> <1277477385.2094.9.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53911 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab0FYRLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 13:11:25 -0400
Received: by yxd5 with SMTP id 5so42522yxd.19
        for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 10:11:24 -0700 (PDT)
In-Reply-To: <1277477385.2094.9.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2010 10:49 AM, Ben Hutchings wrote:
> +static struct cmdline_info cmdline_msglvl[] = {
> +	{ "drv", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_DRV,&msglvl_unwanted },
> +	{ "probe", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_PROBE,&msglvl_unwanted },
> +	{ "link", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_LINK,&msglvl_unwanted },
> +	{ "timer", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_TIMER,&msglvl_unwanted },
> +	{ "ifdown", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_IFDOWN,&msglvl_unwanted },
> +	{ "ifup", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_IFUP,&msglvl_unwanted },
> +	{ "rx_err", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_RX_ERR,&msglvl_unwanted },
> +	{ "tx_err", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_TX_ERR,&msglvl_unwanted },
> +	{ "tx_queued", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_TX_QUEUED,&msglvl_unwanted },
> +	{ "intr", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_INTR,&msglvl_unwanted },
> +	{ "tx_done", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_TX_DONE,&msglvl_unwanted },
> +	{ "rx_status", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_RX_STATUS,&msglvl_unwanted },
> +	{ "pktdata", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_PKTDATA,&msglvl_unwanted },
> +	{ "hw", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_HW,&msglvl_unwanted },
> +	{ "wol", CMDL_FLAG,&msglvl_wanted, NULL,
> +	  NETIF_MSG_WOL,&msglvl_unwanted },


A nice improvement over one-variable-per-bit, I think.

applied patches 1-5, thanks!

	Jeff



P.S.  If you could use my open source email address (jgarzik@pobox.com 
or jeff@garzik.org), that would be greatly appreciated.  @redhat.com is 
only used for sign-offs, as it's less portable than !@redhat.com addresses.

