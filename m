From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH v3 01/12] net: flow_table: create interface for
 hw match/action tables
Date: Thu, 22 Jan 2015 13:37:58 +0900
Message-ID: <20150122043756.GA32765@vergenet.net>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150120202636.1741.86426.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, sfeldma@gmail.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:46826 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbbAVEiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 23:38:11 -0500
Received: by mail-pd0-f169.google.com with SMTP id g10so20989517pdj.0
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 20:38:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150120202636.1741.86426.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 12:26:37PM -0800, John Fastabend wrote:

[snip]

> diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
> new file mode 100644
> index 0000000..7ce1e1d
> --- /dev/null
> +++ b/include/linux/if_flow.h
> @@ -0,0 +1,188 @@

[snip]

> +#define NFL_JUMP_TABLE_DONE 0
> +enum {
> +	NFL_JUMP_ENTRY_UNSPEC,
> +	NFL_JUMP_ENTRY,
> +	__NFL_JUMP_ENTRY_MAX,
> +};

For consistency it seems that the following could go here:

#define NFL_JUMP_ENTRY_MAX (__NFL_JUMP_ENTRY_MAX - 1)

> +enum {
> +	NFL_HEADER_NODE_HDRS_UNSPEC,
> +	NFL_HEADER_NODE_HDRS_VALUE,
> +	__NFL_HEADER_NODE_HDRS_MAX,
> +};
> +
> +#define NFL_HEADER_NODE_HDRS_MAX (__NFL_HEADER_NODE_HDRS_MAX - 1)
> +
> +enum {
> +	NFL_HEADER_NODE_UNSPEC,
> +	NFL_HEADER_NODE_NAME,
> +	NFL_HEADER_NODE_UID,
> +	NFL_HEADER_NODE_HDRS,
> +	NFL_HEADER_NODE_JUMP,
> +	__NFL_HEADER_NODE_MAX,
> +};
> +
> +#define NFL_HEADER_NODE_MAX (__NFL_HEADER_NODE_MAX - 1)
> +
> +enum {
> +	NFL_HEADER_GRAPH_UNSPEC,
> +	NFL_HEADER_GRAPH_NODE,
> +	__NFL_HEADER_GRAPH_MAX,
> +};
> +
> +#define NFL_HEADER_GRAPH_MAX (__NFL_HEADER_GRAPH_MAX - 1)

[snip]
