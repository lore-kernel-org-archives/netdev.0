From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] ip: make IP identifiers less predictable
Date: Fri, 25 Jul 2014 21:57:52 +0200
Message-ID: <1406318272.3363.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1406317840.3363.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1406318067.3363.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeffrey Knockel <jeffk@cs.unm.edu>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:57923 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbaGYT6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 15:58:03 -0400
Received: by mail-wg0-f47.google.com with SMTP id b13so4651442wgh.6
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 12:58:01 -0700 (PDT)
In-Reply-To: <1406318067.3363.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-07-25 at 21:54 +0200, Eric Dumazet wrote:
> On Fri, 2014-07-25 at 21:50 +0200, Eric Dumazet wrote:
> 
> > @@ -1092,6 +1093,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
> >  	skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
> >  				     sizeof(struct frag_hdr)) & ~7;
> >  	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
> > +	fhdr.nexthdr = IPPROTO_UDP;
> >  	ipv6_select_ident(&fhdr, rt);
> >  	skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
> >  
> > 
> > 
> 
> Arg, please ignore this version, this part is buggy.
> 
> I think I wont hash on ipv6 saddr, we might add this later.
> 

Hmpff... false alarm. this is fine. I guess I need to sleep now ;)
