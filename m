From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Fri, 19 Mar 2010 10:28:45 +0200 (EET)
Message-ID: <alpine.LRH.2.00.1003191026150.9778@netcore.fi>
References: <20100110220034.4d46ba8a@nehalam>  <alpine.LRH.2.00.1003180833420.24946@netcore.fi>  <20100318105939.57f8d377@nehalam>  <alpine.LRH.2.00.1003190837210.6428@netcore.fi> <1268986871.3048.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:58221 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628Ab0CSI2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 04:28:52 -0400
In-Reply-To: <1268986871.3048.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Mar 2010, Eric Dumazet wrote:
> This requires that any router in the path between the client and server
> also respects the MINTTL when sending ICMP. Not sure how practical it
> is...

You're correct that with multihop GTSM, ICMP becomes trickier.  I'm 
not sure how applicable GTSM is really in multihop scenarios, though. 
I would not recommend using it to secure e.g. with minttl=250 or 
something that uncontrollable. Your comment relates mainly to ICMP 
soft/hard errors which are not critical for correct operation. 
http://tools.ietf.org/html/draft-ietf-tcpm-icmp-attacks-11 discusses 
this.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
