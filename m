From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Sun, 2 Aug 2009 23:42:37 -0300
Message-ID: <20090803024237.GI25334@ghostprotocols.net>
References: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com> <200907201228.47125.remi.denis-courmont@nokia.com> <1248082487.4549.102.camel@violet> <200907201247.23020.remi.denis-courmont@nokia.com> <1248085261.4549.103.camel@violet> <4A64478D.9030008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58127 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753741AbZHCCov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Aug 2009 22:44:51 -0400
Content-Disposition: inline
In-Reply-To: <4A64478D.9030008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Jul 20, 2009 at 12:31:41PM +0200, Eric Dumazet escreveu:
> Marcel Holtmann a =E9crit :
> > Hi Remi,
> >=20
> >>>>>> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> >>>>> isn't there are proper explaining commit message missing here?
> >>>> AFAIK, a one-liners stick to the Subject line.
> >>>>
> >>>> (I use explicit From: due to my broken Microsoft-provided MTA).
> >>> the From: is not the problem here. However it would be nice to ha=
ve a
> >>> description of the change. Especially details like this is for de=
bugging
> >>> or this is a public API or etc.
> >> It's just like most network protocols exposing their sockets list =
in=20
> >> /proc/net. Debugging/monitoring indeed.
> >=20
> > I think that for new protocols, we should not do this anymore and j=
ust
> > use debugfs. Since that is exactly its job.
>=20
> netstat uses /proc/net
>=20
> iproute2 uses netlink
>=20
> Now you suggest adding debugfs support ?
>=20
> What a mess...

Exactly, the proper way to do that is to have a base class for
inet_diag, net_diag, from where phone would be derived. But yeah, that
requires more work than cut'n'pasting from the old, /proc based way of
doing things 8-)

- Arnaldo
