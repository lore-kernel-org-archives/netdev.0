From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/4] bnx2x: Add Private Flags Support
Date: Wed, 22 May 2013 17:08:17 +0100
Message-ID: <1369238897.2670.11.camel@bwh-desktop.uk.level5networks.com>
References: <1369225359-5578-1-git-send-email-yuvalmin@broadcom.com>
	 <1369225359-5578-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<ariele@broadcom.com>, <eilong@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42875 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176Ab3EVQIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 12:08:20 -0400
In-Reply-To: <1369225359-5578-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 15:22 +0300, Yuval Mintz wrote:
> Utilize ethtool's callback `get_priv_flags' - shed more light on the
> feasibility of devices as storage interfaces.
[...]
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
[...]
> +static const char bnx2x_private_arr[BNX2X_PRI_FLAG_LEN][ETH_GSTRING_LEN] = {
> +	"iSCSI offload support ",
> +	"FCoE offload support  ",
> +	"Storage only interface"
> +};
[...]

No trailing spaces, please.  If you don't like the way private flags are
printed by ethtool, send a patch for ethtool.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
