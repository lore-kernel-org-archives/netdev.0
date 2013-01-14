From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 15/15] batman-adv: unbloat batadv_priv if debug is not
 enabled
Date: Mon, 14 Jan 2013 09:36:40 -0800
Message-ID: <1358185000.19400.15.camel@joe-AO722>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
	 <1358120480-25960-16-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52956 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756450Ab3ANRgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 12:36:31 -0500
In-Reply-To: <1358120480-25960-16-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-14 at 09:41 +1000, Antonio Quartulli wrote:
> diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
[]
> @@ -284,12 +284,16 @@ struct batadv_priv {
>  	atomic_t gw_bandwidth;		/* gw bandwidth */
>  	atomic_t orig_interval;		/* uint */
>  	atomic_t hop_penalty;		/* uint */
> +#ifdef CONFIG_BATMAN_ADV_DEBUG
>  	atomic_t log_level;		/* uint */
> +#endif
>  	atomic_t bcast_seqno;
>  	atomic_t bcast_queue_left;
>  	atomic_t batman_queue_left;
>  	char num_ifaces;
> +#ifdef CONFIG_BATMAN_ADV_DEBUG
>  	struct batadv_debug_log *debug_log;
> +#endif
>  	struct kobject *mesh_obj;
>  	struct dentry *debug_dir;
>  	struct hlist_head forw_bat_list;

How about moving one of these so
there's only one #ifdef block.
