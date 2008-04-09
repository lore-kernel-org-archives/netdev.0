From: Soeren Sonnenburg <kernel@nn7.de>
Subject: Re: [PATCHv2 net-2.6 0/4 (was 0/3)]: TCP fixes
Date: Wed, 09 Apr 2008 07:56:18 +0200
Message-ID: <1207720578.9487.37.camel@localhost>
References: <1207569344-19687-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	 <Pine.LNX.4.64.0804080050060.20948@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J\. Wysocki" <rjw@sisk.pl>,
	"Robin H\. Johnson" <robbat2@gentoo.org>,
	Georgi Chorbadzhiyski <gf@unixsol.org>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Alessandro Suardi <alessandro.suardi@gmail.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nn7.de ([85.214.94.156]:44965 "EHLO nn7.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594AbYDIF5L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 01:57:11 -0400
In-Reply-To: <Pine.LNX.4.64.0804080050060.20948@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-04-08 at 00:59 +0300, Ilpo J=E4rvinen wrote:
> On Mon, 7 Apr 2008, Ilpo J=E4rvinen wrote:
>=20
> > Ok, here's the v2 series=20
>=20
> [...snip...]
>=20
> > ...So far, they're just compile tested. I'll see if I find some tim=
e
> > to boot them on the evening.
>=20
> $ uptime
>  00:53:23 up  1:20,  6 users,  load average: 0.54, 0.22, 0.13
>=20
> ...some torrent & browsing, mainly with tso & tcp_sack =3D 0. Didn't =
hit=20
> any problems with it (I had my debug patch in as well).

I've applied the 4 patches and created massive network load over the
last 12 hours - the problem did not re-appear and the machine is still
alive and kicking.

So I guess you've fixed it :-)
Soeren.
