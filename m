From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v4 1/3] net: TCP thin-stream detection
Date: Wed, 17 Feb 2010 16:32:16 -0800 (PST)
Message-ID: <20100217.163216.50819747.davem@davemloft.net>
References: <4B7AAE60.3070305@simula.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de,
	ebiederm@xmission.com
To: apetlund@simula.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7AAE60.3070305@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Petlund <apetlund@simula.no>
Date: Tue, 16 Feb 2010 15:40:32 +0100

>  
> +/* Determines whether this is a thin stream (which may suffer from
> + * increased latency). Used to trigger latency-reducing mechanisms.*/
> +static inline unsigned int tcp_stream_is_thin(struct tcp_sock *tp)
> +{
> +	return tp->packets_out < 4 && !tcp_in_initial_slowstart(tp);
> +}
> +
>  /* /proc */

Please format comments:

	/* Like this.  */

or:

	/* Like this.
	 * And this.
	 */

Thanks.
