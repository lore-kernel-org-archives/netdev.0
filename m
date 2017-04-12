From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v5 3/5] netlink: allow sending extended ACK
 with cookie on success
Date: Wed, 12 Apr 2017 15:54:31 +0200
Message-ID: <1492005271.2855.6.camel@sipsolutions.net>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
         <20170412123408.22012-4-johannes@sipsolutions.net>
         <20170412134709.GF1952@nanopsycho> (sfid-20170412_154711_878142_644C1B02)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37306 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752345AbdDLNyd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 09:54:33 -0400
In-Reply-To: <20170412134709.GF1952@nanopsycho> (sfid-20170412_154711_878142_644C1B02)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > 	} else {
> > 		flags |= NLM_F_CAPPED;
> > +
> > +		if (nlk->flags & NETLINK_F_EXT_ACK &&
> > +		    extack && extack->cookie_len)
> > +			tlvlen += nla_total_size(extack-
> > >cookie_len);
> > 	}
> > 
> 
> Now I see why you have "if (tlvlen)" where you have it :)

Ah, you had me wondering with that comment ... Yeah, I'd been
developing this by adding patches and then rebasing, so the fact that
this could've been elsewhere to start with never crossed my mind.

johannes
