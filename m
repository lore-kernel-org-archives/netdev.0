From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Re: Linux 2.6.22: Leak r=1 1
Date: Thu, 19 Jul 2007 00:39:48 +0300
Message-ID: <20070718213948.lwpul36asyzannl5@m.safari.iki.fi>
References: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi> <Pine.LNX.4.64.0707181205550.5653@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn2.hy.skanova.net ([81.228.8.111]:48216 "EHLO
	pne-smtpout3-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764188AbXGRWtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:49:20 -0400
Received: from safari.iki.fi (80.223.106.128) by pne-smtpout3-sn2.hy.skanova.net (7.2.075)
        id 469383A1000430CC for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:39:49 +0200
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707181205550.5653@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18, 2007 at 12:16:56 +0300, Ilpo J=E4rvinen wrote:
> On Wed, 11 Jul 2007, Sami Farin wrote:
>=20
> > That's right, so descriptive is the new Linux kernel 2.6.22.
> >=20
> > Linux safari.finland.fbi 2.6.22-cfs-v19 #3 SMP Tue Jul 10 00:22:25 =
EEST 2007 i686 i686 i386 GNU/Linux
> >=20
> > [root@safari /proc/sys/net/ipv4]# grep . *
>=20
> ...snip...
>=20
> > tcp_frto:1
>=20
> ...This is fully unrelated to the issue but I'm a bit curious who ena=
bled=20
> frto on your machine (since it's disabled by default), did you do it =
by=20
> yourself or the distribution perhaps?

I enabled it by myself...

If you'd like to get more widespread testing,
try suggesting Fedora project to add the tuning
to /etc/sysctl.conf (or something like that).
Maybe fedora-devel-list:
http://www.redhat.com/mailman/listinfo/fedora-devel-list
Note that they have antispam on that list which requires
that email address found on From: header field must be
subscribed to the list or otherwise your email is
devnulled.

--=20
Do what you love because life is too short for anything else.

