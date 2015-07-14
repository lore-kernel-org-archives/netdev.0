From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Tue, 14 Jul 2015 18:28:50 +0200
Message-ID: <20150714162850.GA8478@unicorn.suse.cz>
References: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
 <20150714153847.GA3507@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150714153847.GA3507@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2015 at 05:38:47PM +0200, Pablo Neira Ayuso wrote:
> On Tue, Jul 14, 2015 at 02:23:11PM +0200, Michal Kubecek wrote:
> > @@ -658,6 +696,18 @@ static struct ctl_table sctp_sysctl_table[] = {
> >  		.mode		= 0644,
> >  		.proc_handler	= proc_dointvec_jiffies,
> >  	},
> > +	{
> > +		.procname	= "nf_conntrack_sctp_timeout_heartbeat_sent",
> > +		.maxlen		= sizeof(unsigned int),
> > +		.mode		= 0644,
> > +		.proc_handler	= proc_dointvec_jiffies,
> > +	},
> > +	{
> > +		.procname	= "nf_conntrack_sctp_timeout_heartbeat_acked",
> > +		.maxlen		= sizeof(unsigned int),
> > +		.mode		= 0644,
> > +		.proc_handler	= proc_dointvec_jiffies,
> > +	},
> >  	{ }
> >  };
> >  
> > @@ -705,6 +755,18 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
> >  		.mode		= 0644,
> >  		.proc_handler	= proc_dointvec_jiffies,
> >  	},
> > +	{
> > +		.procname	= "ip_conntrack_sctp_timeout_heartbeat_sent",
> > +		.maxlen		= sizeof(unsigned int),
> > +		.mode		= 0644,
> > +		.proc_handler	= proc_dointvec_jiffies,
> > +	},
> > +	{
> > +		.procname	= "ip_conntrack_sctp_timeout_heartbeat_acked",
> > +		.maxlen		= sizeof(unsigned int),
> > +		.mode		= 0644,
> > +		.proc_handler	= proc_dointvec_jiffies,
> > +	},
> >  	{ }
> 
> I don't see the nla_policy updates for the netlink cttimeout
> interface.

I didn't realize those were needed. It means adding two entries to
sctp_timeout_nla_policy and two values to enum ctattr_timeout_sctp?
Or something else is also needed?

                                                        Michal Kubecek
