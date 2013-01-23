From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid
 with wfica
Date: Wed, 23 Jan 2013 23:51:51 +0200
Message-ID: <20130123215151.GF8912@reaktio.net>
References: <20130123161238.GE8912@reaktio.net>
 <20130123214445.GA16641@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:44993 "EHLO smtp.tele.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143Ab3AWVvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 16:51:54 -0500
Received: from ydin.reaktio.net (reaktio.net [194.89.68.22])
	by smtp.tele.fi (Postfix) with ESMTP id 3F6B42348
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 23:51:51 +0200 (EET)
Content-Disposition: inline
In-Reply-To: <20130123214445.GA16641@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 10:44:45PM +0100, Hannes Frederic Sowa wrote:
> On Wed, Jan 23, 2013 at 06:12:38PM +0200, Pasi K=E4rkk=E4inen wrote:
> > My laptop running Fedora 17 randomly crashes when using wfica (Citr=
ix Receiver / ICA Client)=20
> > proprietary closed source client for accessing remote desktop serve=
r.=20
> > wfica is running as a normal user, so it shouldn't be able to cause=
 a kernel crash.=20
> >=20
> > Crashes seem to happen most often when I use either wlan- or 3G mob=
ile data Internet connection.=20
> > These kernel crashes happen ramdomly, often 1-2 times a week.=20
> > What usually happens is that I notice the Internet connection has d=
ied,=20
> > and when I check the kernel dmesg I'm seeing the traceback.=20
> > At this point I'm still able to use the gnome desktop for maybe 1-5=
 minutes,=20
> > but applications start to fail one by one, and finally everything j=
ust halts=20
> > and I need to power cycle the laptop.=20
>=20
> Would it be possible to capture a strace -e network, so we could see =
which
> setsockopt combinations are being applied to the socket. Is capturing=
 ss -ioem
> in such moments still possible?
>=20

I don't think I'm able to strace or anything at that point..=20
It took me at least 10 tries (=3Dcrashes) before I was able to "dmesg >=
 log.txt" successfully ..=20
(usually writing/redirecting to a file fails because the disk/fs is alr=
eady unavailable..)

I can always try though!

Any other ideas?=20

-- Pasi
