From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: dst_release() cleanup
Date: Mon, 7 Dec 2009 10:57:30 -0800
Message-ID: <20091207105730.1fc14c4d@nehalam>
References: <4B1A4BC5.3050300@gmail.com>
	<20091207091746.51d8958a@nehalam>
	<4B1D4573.9040605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48668 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758303AbZLGS5e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 13:57:34 -0500
In-Reply-To: <4B1D4573.9040605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Dec 2009 19:12:03 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> =20
> > I don't like to put actual necessary code in WARN or BUG macro
> > args because some embedded type developer is likely to build
> > with
> >=20
> > #define WARN_ON(x)
> >=20
> > to get rid of all warnings.
>=20
> Oops, I thought WARN_ON(X) must evaluate X once, my bad, since its no=
t documented.
>=20

If done correctly, it would. The correct way to ignore warnings would b=
e to do
something like:

#define WARN_ON(x) (x)


