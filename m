From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 2 Mar 2011 08:11:08 -0800
Message-ID: <20110302081108.689571d8@nehalam>
References: <20110228171738.2cc8c9a0@nehalam>
	<20110302020610.GD1005@gandalf.sssup.it>
	<1299064667.2920.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Checconi <fchecconi@gmail.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55708 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752980Ab1CBQLL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 11:11:11 -0500
In-Reply-To: <1299064667.2920.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Mar 2011 12:17:47 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 02 mars 2011 =E0 03:06 +0100, Fabio Checconi a =E9crit :
> > Hi,
> >=20
> > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > Date: Mon, Feb 28, 2011 05:17:38PM -0800
> > >
> > > This is an implementation of the Quick Fair Queue scheduler devel=
oped
> > > by Fabio Checconi. The same algorithm is already implemented in i=
pfw
> > > in FreeBSD. Fabio had an earlier version developed on Linux, I ju=
st
> > > cleaned it up and tested it. All bugs are mine.
> > >=20
> >=20
> >   thanks for posting, I'm pretty sure that bugs are more likely to =
be
> > ours than yours :)
> >=20
> > During the development of the algorithm we used a simple traffic
> > simulator to verify (informally) the timestamping and the guarantee=
s
> > provided.  I've tested this version of the code with the simulator =
and
> > so far it worked fine, so I think that timestamping and guarantees =
should
> > be OK.
> >=20
> > Please let us know if we can be of any help,
> > fabio
>=20
> Hmm, I tried to setup QFQ (using iproute2patch
> http://patchwork.ozlabs.org/patch/77902/ ) but failed
>=20
> Do you have a link to a script/sample ?
>=20
> Thanks

I put the iproute2 code into the repository in the experimental branch.

--=20
