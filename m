From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Tue, 14 Jul 2015 17:38:47 +0200
Message-ID: <20150714153847.GA3507@salvia>
References: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Michal Kubecek <mkubecek-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150714122311.8DA8EA0C9A-OEaqT8BN2ewCVLCxKZUutA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2015 at 02:23:11PM +0200, Michal Kubecek wrote:
> @@ -658,6 +696,18 @@ static struct ctl_table sctp_sysctl_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
> +	{
> +		.procname	= "nf_conntrack_sctp_timeout_heartbeat_sent",
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_jiffies,
> +	},
> +	{
> +		.procname	= "nf_conntrack_sctp_timeout_heartbeat_acked",
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_jiffies,
> +	},
>  	{ }
>  };
>  
> @@ -705,6 +755,18 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
> +	{
> +		.procname	= "ip_conntrack_sctp_timeout_heartbeat_sent",
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_jiffies,
> +	},
> +	{
> +		.procname	= "ip_conntrack_sctp_timeout_heartbeat_acked",
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_jiffies,
> +	},
>  	{ }

I don't see the nla_policy updates for the netlink cttimeout
interface.
