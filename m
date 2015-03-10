From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH net-next v2 1/1] net: fec: fix receive VLAN CTAG HW
 acceleration issue
Date: Tue, 10 Mar 2015 13:30:45 +0100
Message-ID: <20150310123045.GB952@pengutronix.de>
References: <1425985781-25736-1-git-send-email-b38611@freescale.com>
 <20150310114102.GB22614@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fugang Duan <b38611@freescale.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kernel@pengutronix.de
To: Michael Grzeschik <mgr@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59190 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbbCJMar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 08:30:47 -0400
Content-Disposition: inline
In-Reply-To: <20150310114102.GB22614@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Mar 10, 2015 at 12:41:02PM +0100, Michael Grzeschik wrote:
> On Tue, Mar 10, 2015 at 07:09:41PM +0800, Fugang Duan wrote:
> > The current driver support receive VLAN CTAG HW acceleration featur=
e
> > (NETIF_F_HW_VLAN_CTAG_RX) through software simulation. There calls =
the
> > api .skb_copy_to_linear_data_offset() to skip the VLAN tag, but the=
re
> > have overlap between the two memory data point range. The patch jus=
t fix
> > the issue.
> >=20
> > V2:
> > Michael Grzeschik suggest to use memmove() instead of skb_copy_to_l=
inear_data_offset().
>=20
> This probably is not welcome in the patch description.
>=20
> How about?
>=20
> Cc: <stable@vger.kernel.org> # back to commit 1b7bde6d6
I think the most modern way to do this today is:

	Fixes: 1b7bde6d659d ("net: fec: implement rx_copybreak to improve rx p=
erformance")
	Cc: stable@vger.kernel.org

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
