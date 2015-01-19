From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH v2 02/12] net: flow_table: add flow, delete flow
Date: Mon, 19 Jan 2015 14:06:10 +0900
Message-ID: <20150119050608.GB5612@vergenet.net>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
 <20150113213556.13874.41211.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, sfeldma@gmail.com, netdev@vger.kernel.org,
	gerlitz.or@gmail.com, jhs@mojatatu.com, andy@greyhouse.net,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:41585 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbbASFGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 00:06:22 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so5767806pab.11
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 21:06:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150113213556.13874.41211.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
> index 3e1829e..23dec9b 100644
> --- a/include/linux/if_flow.h
> +++ b/include/linux/if_flow.h
> @@ -185,4 +185,23 @@ struct net_flow_tbl_node {
>  	__u32 flags;
>  	struct net_flow_jump_table *jump;
>  };
> -#endif
> +
> +/**
> + * @struct net_flow_rule
> + * @brief describes the match/action entry
> + *
> + * @uid unique identifier for flow
> + * @priority priority to execute flow match/action in table
> + * @match null terminated set of match uids match criteria
> + * @actoin null terminated set of action uids to apply to match

Hi John,

@action is miss-spelt above.

[snip]
