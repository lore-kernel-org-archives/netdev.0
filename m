From: Nicolas Kaiser <nikai@nikai.net>
Subject: Re: [PATCH net-next-2.6] net/bonding: adjust codingstyle for
 bond_3ad files
Date: Thu, 12 May 2011 01:52:37 +0200
Message-ID: <20110512015237.32d6d92b@absol.kitzblitz>
References: <20110511225208.GA18851@x61.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Joe Perches <joe@perches.com>,
	kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Rafael Aquini <aquini@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webhosting01.bon.m2soft.com ([195.38.20.32]:35123 "EHLO
	webhosting01.bon.m2soft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751568Ab1EKXzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 19:55:54 -0400
In-Reply-To: <20110511225208.GA18851@x61.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Rafael Aquini <aquini@linux.com>:
>         * switched all comments from C99-style to C89-style;

> diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
> index 291dbd4..bc437c3 100644
> --- a/drivers/net/bonding/bond_3ad.h
> +++ b/drivers/net/bonding/bond_3ad.h

> @@ -246,30 +257,32 @@ struct ad_system {
>  #pragma pack()
>  #endif
>  
> -// ================= AD Exported structures to the main bonding code ==================
> +/* ============ AD Exported structures to the main bonding code ============ */
>  #define BOND_AD_INFO(bond)   ((bond)->ad_info)
>  #define SLAVE_AD_INFO(slave) ((slave)->ad_info)

> -// ================= AD Exported functions to the main bonding code ==================
> -void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
> +// ============= AD Exported functions to the main bonding code ============ */
   ^^
   /*

Cheers,
Nicolas Kaiser
