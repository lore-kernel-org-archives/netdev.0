From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in
 ip_tunnel_xmit
Date: Wed, 25 Sep 2013 14:13:37 +0200
Message-ID: <20130925121337.GZ7660@secunet.com>
References: <20130925055418.GV7660@secunet.com>
 <1380110163.3165.138.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33990 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755119Ab3IYMNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 08:13:40 -0400
Content-Disposition: inline
In-Reply-To: <1380110163.3165.138.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 04:56:03AM -0700, Eric Dumazet wrote:
> On Wed, 2013-09-25 at 07:54 +0200, Steffen Klassert wrote:
> > We might extend the used aera of a skb beyond the total
> > headroom when we install the ipip header. Fix this by
> > calling skb_cow_head() unconditionally.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> >  net/ipv4/ip_tunnel.c |   12 ++++++------
> >  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> Do you know or can we find when was the bug introduced ?

It was commit c544193214 (GRE: Refactor GRE tunneling code.)
when net/ipv4/ip_tunnel.c was created.

> 
> (commit id and title in your changelog would be really nice)
> 

I can send a v2 with these informations included if you want
that.
