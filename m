From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Wed, 16 Jun 2010 11:08:04 +0200
Message-ID: <1276679284.2632.22.camel@edumazet-laptop>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>
	 <1276466190.14011.223.camel@localhost>
	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>
	 <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>
	 <4C1662C3.3070708@trash.net> <1276542772.2444.13.camel@edumazet-laptop>
	 <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Pedro Garcia <pedro.netdev@dondevamos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37186 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab0FPJII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 05:08:08 -0400
Received: by wyb40 with SMTP id 40so5481296wyb.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 02:08:06 -0700 (PDT)
In-Reply-To: <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 juin 2010 =C3=A0 10:49 +0200, Pedro Garcia a =C3=A9crit =
:
> On Mon, 14 Jun 2010 21:12:52 +0200, Eric Dumazet <eric.dumazet@gmail.=
com>

> > Good luck for your first patch !
>=20
> Here it is again. I added the modifications in http://kerneltrap.org/=
mailarchive/linux-netdev/2010/5/23/6277868 for HW accelerated incoming =
packets (it did not apply cleanly on the last version of
> the kernel, so I applied manually). Now, if the VLAN 0 is not explici=
tly created by the user, VLAN 0 packets will be treated as no VLAN (802=
=2E1p packets), instead of dropping them.
>=20
> The patch is now for two files: vlan_core (accel) and vlan_dev (non a=
ccel)
>=20
> I can not test on HW accelerated devices, so if someone can check it =
I will appreciate (even though in the thread above it looked like yes).=
 For non accel I tessted in 2.6.26. Now the patch is for
> net-next-2.6, and it compiles OK, but I a have to setup a test enviro=
nment to check it is still OK (should, but better to test).
>=20
> Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>

OK, the patch itself is correct.

Now, could you please send it again with a proper changelog ?

In this changelog, please explain why patch is needed, and
keep lines short (< 72 chars), like the one you did in your first mail.

I'll then add my Signed-off-by, since I wrote the accelerated part ;)

Note : I wonder if another patch is needed, in case 8021q module is
_not_ loaded. We probably should accept vlan 0 frames in this case ?


