From: "David S. Miller" <davem@redhat.com>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Mon, 9 Feb 2004 12:19:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209121926.6f016ebf.davem@redhat.com>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 8 Feb 2004 22:44:05 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> - the 'skb->pkt_type == PACKET_HOST' check has no semantic anymore,
> the requestor should have same information no matter the packet
> type. In all cases we add response delay for all requests, broadcast
> or unicast, to help other authoritative hosts to reply before us.

Do we really want to reply to all the garbage tcpdump causes us
to capture?

That is what the pkt_type is dealing with.  If we're in promiscuous
mode, we'll hear ARP requests meant not for any of our devices, we
should not proxy for them right?

RTCF_*NAT is dead wood, the existing route nating stuff is totally broken
an unusable in 2.6.x, the eventual plan was to code up XFRM engine version
of that feature but this is of course not done.  Since nobody is complaining
about lack of routing NAT in 2.6.x, I think we should just kill off all references
and if someone gets inspired they can code up the XFRM engine version.
