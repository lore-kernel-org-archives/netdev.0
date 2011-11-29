From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 16:41:29 +0000
Message-ID: <1322584889.2684.25.camel@bwh-desktop>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	 <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	 <1322550138.2970.70.camel@edumazet-laptop>
	 <1322576645.7454.48.camel@deadeye>
	 <1322576986.2465.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw5UG4=QRN3Wnh82wRg8YCSV7vDqGp0HyeVxsihUwLuioQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16278 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754793Ab1K2Qld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 11:41:33 -0500
In-Reply-To: <CAA93jw5UG4=QRN3Wnh82wRg8YCSV7vDqGp0HyeVxsihUwLuioQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-29 at 17:06 +0100, Dave Taht wrote:
> On Tue, Nov 29, 2011 at 3:29 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le mardi 29 novembre 2011 =C3=A0 14:24 +0000, Ben Hutchings a =C3=A9=
crit :
> >
> >> Not if you separate hardware queues by priority (and your high pri=
ority
> >> packets are non-TCP or PuSHed).
> >
> > I mostly have tg3 , bnx2 cards, mono queues...
> >
> > I presume Dave, working on small Wifi/ADSL routers have same kind o=
f
> > hardware.
>=20
> Nothing but mono queues here on wired - 4 queues on wireless, however=
=2E
>=20
> and a focus on trying to make sure the
> 10Gig guys don't swamp the 128Kbit to 100Mbit guys, and everything in
> between that bandwidth range is what I care about, mostly against Gig=
E
> servers...

I'm not objecting to that, just the assertion that TSO can be a problem
even on 10G hardware.  In fact it makes a big improvement to CPU
efficiency (even if you do it in the driver, it can be better than GSO)
and almost all 10G hardware has multiple queues which can be used to
avoid the latency penalty.

> ( I'm still waiting on some 10Gig hw donations to arrive)
[...]

If you have a proposal to do interesting things with 10G hardware and
drivers then I can forward it for consideration here.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
