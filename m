From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [PATCH 0/3] gigaset fixes for 2.6.34-rc1
Date: Mon, 15 Mar 2010 16:00:29 +0100
Message-ID: <201003151600.29048.isdn@linux-pingi.de>
References: <cover.1268580322.git.tilman@imap.cc>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	i4ldeveloper <i4ldeveloper@listserv.isdn4linux.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1268580322.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sonntag, 14. M=E4rz 2010 23:58:05 Tilman Schmidt wrote:
> Karsten, David,
>=20
> following are three bugfix patches to the Gigaset driver which should
> still go into 2.6.34 if possible, and also into the 2.6.33 stable bra=
nch.

Ack for all

>=20
> Thanks,
> Tilman
>=20
> Tilman Schmidt (3):
>   gigaset: avoid registering CAPI driver more than once
>   gigaset: correct clearing of at_state strings on RING
>   gigaset: prune use of tty_buffer_request_room
>=20
>  drivers/isdn/gigaset/capi.c      |   44
>  +++++++++++++++++++++---------------- drivers/isdn/gigaset/common.c =
   | =20
>   6 +++-
>  drivers/isdn/gigaset/ev-layer.c  |   12 +++-------
>  drivers/isdn/gigaset/gigaset.h   |    6 +++-
>  drivers/isdn/gigaset/i4l.c       |   28 +++++++++++++++++-------
>  drivers/isdn/gigaset/interface.c |    1 -
>  6 files changed, 57 insertions(+), 40 deletions(-)
>=20
