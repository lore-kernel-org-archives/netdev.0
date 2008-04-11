From: Jeremy Jackson <jerj@coplanar.net>
Subject: Re: Re-queueing of skb in vlan_skb_recv
Date: Fri, 11 Apr 2008 08:53:24 -0400
Message-ID: <1207918405.22152.97.camel@ragnarok>
References: <8A9D56C5E50F774BABE033F1710B357601084C42@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
	 <47FF5DAB.1060906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brian Oostenbrink <Brian_Oostenbrink@pmc-sierra.com>,
	linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <47FF5DAB.1060906@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-04-11 at 14:46 +0200, Patrick McHardy wrote:
> Brian Oostenbrink wrote:
> > In vlan_skb_recv, packets are generally stripped of their vlan header,
> > and then re-queued via netif_rx().  Is there a reason for re-queuing
> > these instead of calling netif_receive_skb() directly?  On our system
> > (an embedded linux router), this re-queuing has a significant
> > performance penalty.
> 
> Its done to save stack space. There's currently a discussion
> about making loopback use netif_receive_skb in case enough
> stack is still available. Once that patch gets merged I'll
> change VLAN in a similar way.

There was a patch floating around fixing VLAN + Bridge, I'm wondering if
it got any traction (ie merged), or if this would affect future merge of
that feature?


-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

