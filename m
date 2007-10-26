From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [TCP]: fix D-SACK cwnd handling
Date: Fri, 26 Oct 2007 04:28:18 -0700 (PDT)
Message-ID: <20071026.042818.263025603.davem@davemloft.net>
References: <20071025.171147.107738702.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	y-kodama@aist.go.jp
To: takano-ryousei@aist.go.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58739
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750699AbXJZL2Q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 07:28:16 -0400
In-Reply-To: <20071025.171147.107738702.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ryousei Takano <takano-ryousei@aist.go.jp>
Date: Thu, 25 Oct 2007 17:11:47 +0900 (JST)

> In the current net-2.6 kernel, handling FLAG_DSACKING_ACK is broken.
> The flag is cleared to 1 just after FLAG_DSACKING_ACK is set.
>=20
>         if (found_dup_sack)
>                 flag |=3D FLAG_DSACKING_ACK;
> 	:
> 	flag =3D 1;
>=20
> To fix it, this patch introduces a part of the tcp_sacktag_state patc=
h:
> 	http://marc.info/?l=3Dlinux-netdev&m=3D119210560431519&w=3D2
>=20
> Do you plan to apply the tcp_sacktag_state patch?
> Or please apply this patch.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>

I've applied this patch, thank you!

