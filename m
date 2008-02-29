From: Bill Fink <billfink@mindspring.com>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2054 tcp_mark_head_lost()
Date: Thu, 28 Feb 2008 23:35:14 -0500
Message-ID: <20080228233514.63b7136e.billfink@mindspring.com>
References: <858077.97160.qm@web39709.mail.mud.yahoo.com>
	<20080223000310.4630daa8.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802271108290.13029@kivilampi-30.cs.helsinki.fi>
	<3d8471ca0802271056l320a7ee2m5227e114a968d483@mail.gmail.com>
	<Pine.LNX.4.64.0802272120430.1741@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0802281018480.32401@kivilampi-30.cs.helsinki.fi>
	<20080228171011.fc56eace.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ilpo =?ISO-8859-1?Q?J=E4rvinen" ?= <ilpo.jarvinen@helsinki.fi>,
	Guillaume Chazarain <guichaz@gmail.com>,
	Giangiacomo Mariotti <giangiacomo_mariotti@yahoo.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:38951 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755642AbYB2Ef3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 23:35:29 -0500
In-Reply-To: <20080228171011.fc56eace.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Feb 2008, Andrew Morton wrote:

> On Thu, 28 Feb 2008 10:22:27 +0200 (EET) "Ilpo J=E4rvinen" <ilpo.jarv=
inen@helsinki.fi> wrote:
>=20
> > [PATCH] TCP debug S+L (for 2.6.25-rcs, incompatible with 2.6.24.y)
> >=20
> > ---
> >  include/net/tcp.h     |    9 +++-
> >  net/ipv4/tcp_input.c  |   18 +++++++-
> >  net/ipv4/tcp_ipv4.c   |  127 +++++++++++++++++++++++++++++++++++++=
++++++++++++
> >  net/ipv4/tcp_output.c |   23 +++++++--
>=20
> I'll put this in -mm, see if we can flush anything out.  Please let m=
e know
> if/when it's obsolete, updated, etc.
>=20
> What is "S+L"?

I'll let Ilpo give the definitive answer.  But to test if I'm starting
to grasp this, I'll give my understanding.  I believe 'S' means that a
transmitted TCP skb has been acknowledged by a SACK, while 'L' means
that a transmitted SKB is believed lost.  Since the 'S' state implies
that the packet has actually been successfully received, it should not =
be
possible for it to be considered lost ('L' state).  Thus an "S+L" state
for a TCP skb is an internally inconsistent state and an indication of
a TCP bug.

Anyone feel free to correct me if I'm way off base in my understanding.

						-Bill
