From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next 3/4] net: dsa: mv88e6xxx: Move the tagging
 protocol into info
Date: Fri, 2 Dec 2016 22:02:02 +0100
Message-ID: <20161202210202.GE30716@lunn.ch>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch>
 <1480701779-30633-4-git-send-email-andrew@lunn.ch>
 <87k2bice5n.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38231 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751695AbcLBVCG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 16:02:06 -0500
Content-Disposition: inline
In-Reply-To: <87k2bice5n.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 02:41:08PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > @@ -3749,6 +3756,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
> >  		.global1_addr = 0x1b,
> >  		.age_time_coeff = 15000,
> >  		.g1_irqs = 9,
> > +		.tag_protocol = DSA_TAG_PROTO_EDSA,
> >  		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
> >  		.ops = &mv88e6172_ops,
> >  	},
> 
> Since some chips support several protocols, we will have to turn
> tag_protocol into a bitmask and introduce something like:

Why? We have made an implementation choice, this chip will be used in
this way. There is no strong reason to use it the other way. There is
a strong reason not to allow it to be configured, because it makes the
driver more complex and the DSA layer more complex, and no other
driver requires this complexity.

KISS.

	Andrew
