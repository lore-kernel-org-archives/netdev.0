From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Tue, 10 Feb 2004 00:32:56 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402100026180.1251@u.domain.uli>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
 <20040209121926.6f016ebf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209121926.6f016ebf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 9 Feb 2004, David S. Miller wrote:

> > - the 'skb->pkt_type == PACKET_HOST' check has no semantic anymore,
> > the requestor should have same information no matter the packet
> > type. In all cases we add response delay for all requests, broadcast
> > or unicast, to help other authoritative hosts to reply before us.
>
> Do we really want to reply to all the garbage tcpdump causes us
> to capture?
>
> That is what the pkt_type is dealing with.  If we're in promiscuous
> mode, we'll hear ARP requests meant not for any of our devices, we
> should not proxy for them right?

	But this is true for local TIPs too. Do we need early check for
{HOST|BROADCAST} or you prefer it only for the proxy_arp case?

> RTCF_*NAT is dead wood, the existing route nating stuff is totally broken
> an unusable in 2.6.x, the eventual plan was to code up XFRM engine version
> of that feature but this is of course not done.  Since nobody is complaining
> about lack of routing NAT in 2.6.x, I think we should just kill off all references
> and if someone gets inspired they can code up the XFRM engine version.

	I complained once but everything is doable with netfilter,
with more rules, of course.

Regards

--
Julian Anastasov <ja@ssi.bg>
