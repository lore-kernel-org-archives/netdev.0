From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 17:50:51 +0100
Message-ID: <20170223165051.c3jlvht4mhsuoxmq@nataraja>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com>
 <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net>
 <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com>
 <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
 <7810166.196078.1487842556962.JavaMail.zimbra@tpip.net>
 <20170223140012.GA4462@salvia>
 <CALx6S37QT-3W5psz0f2bf+RTzt09AysCtwTQmzZsHS_g6uo5ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Andreas Schultz <aschultz@tpip.net>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        netdev <netdev@vger.kernel.org>,
        timo lindhorst <timo.lindhorst@travelping.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:54217 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751191AbdBWQwH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 11:52:07 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S37QT-3W5psz0f2bf+RTzt09AysCtwTQmzZsHS_g6uo5ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, Feb 23, 2017 at 08:35:13AM -0800, Tom Herbert wrote:
> On Thu, Feb 23, 2017 at 6:00 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Thu, Feb 23, 2017 at 10:35:56AM +0100, Andreas Schultz wrote:
> >> ----- On Feb 22, 2017, at 10:47 PM, Tom Herbert tom@herbertland.com wrote:
> >> So in a complete 3GPP node (GGSN, P-GW) that uses the GTP tunnel
> >> implementation, malicious traffic should be blocked before it can reach
> >> the tunnel.
> >>
> >> And as I stated before, the GTP tunnel module is not supposed to be
> >> use without any of those components. So the DDOS concern should not
> >> be handled at the tunnel level.
> >
> > I think that Tom's point is that this tunnel driver will have to deal
> > with DDOS scenarios anyway, because reality is that you can't always
> > block it before it can reach the tunnel.
> >
> Right, if only we had a dime for every time someone thought their
> perimeter security was sufficient only to be proven wrong!

Yes and no.  Welcome to the cellular world. Everything is designed in
a way that it assumes everyone can be trusted and that none of those
interfaces (except the radio interface) are ever exposed to the public.

There is really very little one can do to change that world.  It's like
the Internet in the early 1990ies, and they are reluctant to learn.  And
whenever a new system is designed (like the step from MAP to DIAMETER),
they make damn sure that all the security issues are inherited from the
previous standards to ensure interoperability ;)

I understand and support the motivation to design robust systsems even
in the presence of broken/ignorant specs, but I think this is one of the
situations where it is useless (and IMHO impossible) to do anything
about it.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
