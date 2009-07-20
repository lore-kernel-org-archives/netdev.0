From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 12:21:01 +0200
Message-ID: <1248085261.4549.103.camel@violet>
References: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com>
	 <200907201228.47125.remi.denis-courmont@nokia.com>
	 <1248082487.4549.102.camel@violet>
	 <200907201247.23020.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33734 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbZGTKVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 06:21:32 -0400
In-Reply-To: <200907201247.23020.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

> > > > > From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
> > > >
> > > > isn't there are proper explaining commit message missing here?
> > >
> > > AFAIK, a one-liners stick to the Subject line.
> > >
> > > (I use explicit From: due to my broken Microsoft-provided MTA).
> >
> > the From: is not the problem here. However it would be nice to have=
 a
> > description of the change. Especially details like this is for debu=
gging
> > or this is a public API or etc.
>=20
> It's just like most network protocols exposing their sockets list in=20
> /proc/net. Debugging/monitoring indeed.

I think that for new protocols, we should not do this anymore and just
use debugfs. Since that is exactly its job.

Regards

Marcel


