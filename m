From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] be2net: Add description about various RSS
 hash types
Date: Fri, 13 Jul 2012 15:20:27 +0200
Message-ID: <1342185627.3265.8357.camel@edumazet-glaptop>
References: <ecab14f7-24e9-4329-9d62-640086a29b52@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54542 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab2GMNUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 09:20:33 -0400
Received: by bkwj10 with SMTP id j10so3100792bkw.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 06:20:32 -0700 (PDT)
In-Reply-To: <ecab14f7-24e9-4329-9d62-640086a29b52@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-13 at 18:15 +0530, Padmanabh Ratnakar wrote:
> Incorporated review comment from Eric Dumazet. Added description
> about different RSS hash types which adapter is capable of.
> Will add support for ETHTOOL_GRXFH and ETHTOOL_SRXFX as suggested
> by Ben Hutchings in a later patch.
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_cmds.h |   14 ++++++++++++--
>  1 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
> index 45d70de..d5a4ded 100644
> --- a/drivers/net/ethernet/emulex/benet/be_cmds.h
> +++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
> @@ -1082,8 +1082,18 @@ struct be_cmd_resp_query_fw_cfg {
>  	u32 function_caps;
>  };
>  
> -/******************** RSS Config *******************/
> -/* RSS types */
> +/******************** RSS Config ****************************************/
> +/* RSS type		Input parameters used to compute RX hash
> + * RSS_ENABLE_IPV4	SRC IPv4, DST IPv4
> + * RSS_ENABLE_TCP_IPV4	SRC IPv4, DST IPv4, TCP SRC PORT, TCP DST PORT
> + * RSS_ENABLE_IPV6	SRC IPv6, DST IPv6
> + * RSS_ENABLE_TCP_IPV6	SRC IPv6, DST IPv6, TCP SRC PORT, TCP DST PORT
> + * RSS_ENABLE_UDP_IPV4	SRC IPv4, DST IPv4, UDP SRC PORT, UDP DST PORT
> + * RSS_ENABLE_UDP_IPV6	SRC IPv6, DST IPv6, UDP SRC PORT, UDP DST PORT
> + *
> + * When multiple RSS types are enabled, HW picks the best hash policy
> + * based on the type of the received packet.
> + */
>  #define RSS_ENABLE_NONE				0x0
>  #define RSS_ENABLE_IPV4				0x1
>  #define RSS_ENABLE_TCP_IPV4			0x2

Thanks

Acked-by: Eric Dumazet <edumazet@google.com>
