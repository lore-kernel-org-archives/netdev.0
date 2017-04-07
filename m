From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 7 Apr 2017 21:02:04 +0200
Message-ID: <20170407190204.GA22810@salvia>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
 <20170407.115315.23470877439489670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56666 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933977AbdDGTCK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:02:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AF9D41395D0
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:02:06 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A149ADA862
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:02:06 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9AD60DA872
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:02:04 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170407.115315.23470877439489670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 11:53:15AM -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Fri,  7 Apr 2017 20:26:17 +0200
> 
> > So this is my first draft of what we'd talked about at netconf.
> > I'm not super happy with the way we have to pass the extended
> > error struct, but I don't see a way to implement reporting any
> > dynamic information (like error offsets) in any other way.
> > 
> > Alexander Shishkin had a nice way of reporting static extended
> > error data, but that isn't really suitable for reporting the
> > offset or even reporting the broken attribute from nla_parse().
> > 
> > Speaking of nla_parse(), that'll be somewhat complicated to do
> > since we'll have to track the offsets of where we're parsing,
> > but it might be possible since the nlattrs are just pointers
> > into the message, so (optionally?) passing the skb as well can
> > allow us to fill the offset information.
> 
> I like it, nice work.
> 
> I know people want dynamically generated strings and stuff, and we can
> get there, but I prefer that the first thing we commit is super simple.
> 
> Someone gave me a hard time about the fact that we've been talking
> about this idea for years but nothing ever happens.
> 
> I'm tempted to apply this as-is just to show that person that things
> do in fact happen.... eventually :-)

We can just send follow up patches to refine, I think it's a good
start, Johannes?

BTW, for this co-authored effort in designing this:

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Thanks!
