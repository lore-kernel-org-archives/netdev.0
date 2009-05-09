From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ports beeing reused too fast
Date: Sat, 9 May 2009 15:45:15 -0700
Message-ID: <20090509154515.28251a48@nehalam>
References: <200905082311.09414.opurdila@ixiacom.com>
	<4A052991.5040009@cosmosbay.com>
	<200905091611.20321.opurdila@ixiacom.com>
	<4A059E75.7060008@cosmosbay.com>
	<20090509153135.04874f72.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41840 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626AbZEIWpU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 18:45:20 -0400
In-Reply-To: <20090509153135.04874f72.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 May 2009 15:31:35 -0400
Bill Fink <billfink@mindspring.com> wrote:

> On Sat, 09 May 2009, Eric Dumazet wrote:
>=20
> > Octavian Purdila a =C3=A9crit :
> > > On Saturday 09 May 2009 09:58:25 Eric Dumazet wrote:
> > >=20
> > >>> I've looked over the  code and it looks right, so maybe net_ran=
dom() is
> > >>> not random enough? Or maybe there are side effects because of t=
he %
> > >>> port_range?
> > >> Random is random :)
> > >> Probability a port can be reused pretty fast is not nul.
> > >>
> > >=20
> > > Thinking again about it... you are right :)
> > >=20
> > >> So yes, behavior you discovered is expected, when we switched po=
rt
> > >> selection from a sequential one (not very secure btw) to a rando=
m one.
> > >>
> > >> Any strong reason why a firewall would drop a SYN because ports =
were used
> > >> in a previous session ?
> > >=20
> > > We don't know why the firewall (Cisco FWSM) is dropping the packe=
ts, may be a=20
> > > bug, limitation or miss-configuration. We are trying to track thi=
s down with=20
> > > the firewall vendor.
> >=20
> > Normally, the client machine should not reuse a port during the TIM=
E_WAIT duration
> > (TCP_TIMEWAIT_LEN being 60 seconds on linux). Port selection being =
random or sequential,
> > it should avoid all ports recently used.
> >=20
> > Maybe this firewall has a longer TIME_WAIT enforcement (something l=
ike 2 minutes)
>=20
> But he had 19 ports being reused after only 1000 connect()s, which
> with his stated ~360 (I'm assuming per second) connection rate,
> would only take about 3 seconds.
>=20
> 						-Bill

This the same thing as the Birthday paradox

--=20
