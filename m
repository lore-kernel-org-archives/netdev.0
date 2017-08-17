From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] dsa: remove unused net_device arg from handlers
Date: Thu, 17 Aug 2017 20:40:58 +0200
Message-ID: <20170817184058.GA7154@breakpoint.cc>
References: <20170817144700.16218-1-fw@strlen.de>
 <20170817182116.GE21715@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58030 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752872AbdHQSnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 14:43:24 -0400
Content-Disposition: inline
In-Reply-To: <20170817182116.GE21715@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> wrote:
> On Thu, Aug 17, 2017 at 04:47:00PM +0200, Florian Westphal wrote:
> > compile tested only, but saw no warnings/errors with
> > allmodconfig build.
> >  
> >  static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
> > -			  struct packet_type *pt, struct net_device *orig_dev)
> > +			  struct packet_type *pt, struct net_device *unused)
> 
> Hi Florian
> 
> Looks O.K. to me. I can test it out later.
> 
> Is there a bigger picture here? Do you plan to remove the second
> net_device parameter everywhere?

Its tempting, seems only af_packet uses it.  I'll see if there is
another (simpler) way of getting the orig ifindex into af_packet.
