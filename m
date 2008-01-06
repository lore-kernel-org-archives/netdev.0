From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Sat, 05 Jan 2008 23:13:29 -0800 (PST)
Message-ID: <20080105.231329.41382737.davem@davemloft.net>
References: <11995403481730-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751532AbYAFHN3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2008 02:13:29 -0500
In-Reply-To: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat,  5 Jan 2008 15:39:07 +0200

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> net/xfrm/xfrm_state.c:
>   xfrm_audit_state_delete          | -589
>   xfrm_replay_check                | -542
>   xfrm_audit_state_icvfail         | -520
>   xfrm_audit_state_add             | -589
>   xfrm_audit_state_replay_overflow | -523
>   xfrm_audit_state_notfound_simple | -509
>   xfrm_audit_state_notfound        | -521
>  7 functions changed, 3793 bytes removed, diff: -3793
>=20
> net/xfrm/xfrm_state.c:
>   xfrm_audit_helper_pktinfo | +522
>   xfrm_audit_helper_sainfo  | +598
>  2 functions changed, 1120 bytes added, diff: +1120
>=20
> net/xfrm/xfrm_state.o:
>  9 functions changed, 1120 bytes added, 3793 bytes removed, diff: -26=
73
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
