From: Michal Kubecek <mkubecek-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Thu, 16 Jul 2015 18:13:42 +0200
Message-ID: <20150716161342.GA17960@unicorn.suse.cz>
References: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
 <20150716135059.GB14704@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Marcelo Ricardo Leitner <marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150716135059.GB14704-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 16, 2015 at 10:50:59AM -0300, Marcelo Ricardo Leitner wrote:
> On Tue, Jul 14, 2015 at 02:23:11PM +0200, Michal Kubecek wrote:
> > @@ -278,6 +292,14 @@ static int sctp_new_state(enum ip_conntrack_dir dir,
> >  		pr_debug("SCTP_CID_SHUTDOWN_COMPLETE\n");
> >  		i = 8;
> >  		break;
> > +	case SCTP_CID_HEARTBEAT:
> > +		pr_debug("SCTP_CID_HEARTBEAT");
> > +		i = 9;
> > +		break;
> > +	case SCTP_CID_HEARTBEAT_ACK:
> > +		pr_debug("SCTP_CID_HEARTBEAT_ACK");
> > +		i = 10;
> > +		break;
> >  	default:
> >  		/* Other chunks like DATA, SACK, HEARTBEAT and
> >  		its ACK do not cause a change in state */
> 
> Would you update this comment on default case please? As with this
> patch, HB and its ACK may cause a change in state.

Thank you for catching this. I'll update the comment in v2 I'm going to
send tomorrow after some testing.

                                                         Michal Kubecek
