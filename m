From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid with wfica
Date: Wed, 23 Jan 2013 22:44:45 +0100
Message-ID: <20130123214445.GA16641@order.stressinduktion.org>
References: <20130123161238.GE8912@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47252 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052Ab3AWVor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 16:44:47 -0500
Content-Disposition: inline
In-Reply-To: <20130123161238.GE8912@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 06:12:38PM +0200, Pasi K=C3=A4rkk=C3=A4inen wro=
te:
> My laptop running Fedora 17 randomly crashes when using wfica (Citrix=
 Receiver / ICA Client)=20
> proprietary closed source client for accessing remote desktop server.=
=20
> wfica is running as a normal user, so it shouldn't be able to cause a=
 kernel crash.=20
>=20
> Crashes seem to happen most often when I use either wlan- or 3G mobil=
e data Internet connection.=20
> These kernel crashes happen ramdomly, often 1-2 times a week.=20
> What usually happens is that I notice the Internet connection has die=
d,=20
> and when I check the kernel dmesg I'm seeing the traceback.=20
> At this point I'm still able to use the gnome desktop for maybe 1-5 m=
inutes,=20
> but applications start to fail one by one, and finally everything jus=
t halts=20
> and I need to power cycle the laptop.=20

Would it be possible to capture a strace -e network, so we could see wh=
ich
setsockopt combinations are being applied to the socket. Is capturing s=
s -ioem
in such moments still possible?

Thanks,

  Hannes
