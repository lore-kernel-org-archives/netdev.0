From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Why can't we SNAT (or inverse DNAT) in PREROUTING?
Date: Sat, 27 Jun 2015 10:50:07 +0200
Message-ID: <20150627085007.GA4910@electric-eye.fr.zoreil.com>
References: <CALCETrWRv5S_X=MQRGwO-NR+XrQc2o-EnooHFN0V41xqJEY8sA@mail.gmail.com>
 <20150626203249.GA28820@electric-eye.fr.zoreil.com>
 <CALCETrUR9VKJ0jJwqF79Jm6Y954yhMrA=ifzRWCvvgHzOpgzag@mail.gmail.com>
 <20150626224825.GB28820@electric-eye.fr.zoreil.com>
 <CALCETrVupw4uJN68skaUJH+zrEyGt7MagfMeTpdTqb1zQ7FB5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55644 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755292AbbF0IuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 04:50:19 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrVupw4uJN68skaUJH+zrEyGt7MagfMeTpdTqb1zQ7FB5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> :
> On Fri, Jun 26, 2015 at 3:48 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > Andy Lutomirski <luto@amacapital.net> :
[...]
> >> Shouldn't the order of operations be:
> >>
> >> 1. Check rp_filter.
> >> 2. Handle NAT.
> >> 3. Routing decision.
> >> ?
> >
> > The admittedly painful fwmark part would still be needed for pre-NAT
> > source address based policy routing (assuming SNAT loses valuable policy
> > information). Life would be easier for your current requirements but
> > some different policy requirements would be unable to avoid the
> > fwmark/mangle style stuff.
> 
> What kind of policy routing would care about the pre-NAT source
> address?  AIUI, the usual use of policy routing is to *route*, not to
> filter. But maybe I'm missing something.

?

The same could be said regarding your (post NAT) source address policy
routing requirement.

> > Btw, the suggested scheme implies that filtering between SNAT and DNAT
> > would be done before routing, thus without INPUT vs FORWARD tainting.
> 
> What do you mean by "filtering between SNAT and DNAT"?

I had Jan Engelhardt's netfilter packet flow diagram in mind.

Replacing it with a 3 steps packet processing conceptual flow does not
seem trivial to me.

-- 
Ueimor
