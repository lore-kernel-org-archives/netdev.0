From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Wed, 6 Feb 2013 17:25:19 +0100
Message-ID: <20130206162519.GA19537@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se> <20130206134950.GD10290@order.stressinduktion.org> <51127781.2000504@linux-ipv6.org> <20130206160409.GB18040@order.stressinduktion.org> <1360167527.28557.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47813 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757587Ab3BFQZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 11:25:20 -0500
Content-Disposition: inline
In-Reply-To: <1360167527.28557.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 08:18:47AM -0800, Eric Dumazet wrote:
> On Wed, 2013-02-06 at 17:04 +0100, Hannes Frederic Sowa wrote:
> > On Thu, Feb 07, 2013 at 12:32:17AM +0900, YOSHIFUJI Hideaki wrote:
> 
> > > Well, do you have relevant RFC?
> > > RFC4291 says that we should drop ff00::/16, but not ff01::/16.
> > 
> > I know what you mean, the RFC does not state it directly. Hm, the BSDs seem to
> > drop such destination addresses, too, if they don't originate from a loopback
> > interface. Or did you mean that there is a flaw in the skb->pkt_type !=
> > PACKET_LOOPBACK condition?
> 
> RFC 4291 states on page 13 :
> 
>  Interface-Local scope spans only a single interface on a node
>  and is useful only for loopback transmission of multicast.
> 
> ff01::/16 are Interface-Local, or am I missing something ?

No, that's correct.
