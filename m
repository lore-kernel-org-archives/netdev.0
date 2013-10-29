From: Nathan Hintz <nlhintz@hotmail.com>
Subject: Re: [PATCH] bgmac: don't update slot on skb alloc/dma mapping error
Date: Tue, 29 Oct 2013 08:20:08 -0700
Message-ID: <BLU0-SMTP163BBDC6542FBE427D35350AC090@phx.gbl>
References: <BLU0-SMTP119F7A71B34291D1CC2486BAC090@phx.gbl>
	<CACna6rzxt2QMtLfD84pw7EtYqg1Qva4ah83hVQOKpeKy72bd5w@mail.gmail.com>
	<BLU0-SMTP200803D333FF3A2F15AB82DAC090@phx.gbl>
	<CACna6rzqwz_wp=9ayX6AUZvVSNwdAg-LniXtNwy9eRFDEoNspg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu0-omc1-s18.blu0.hotmail.com ([65.55.116.29]:55585 "EHLO
	blu0-omc1-s18.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753508Ab3J2PUL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 11:20:11 -0400
In-Reply-To: <CACna6rzqwz_wp=9ayX6AUZvVSNwdAg-LniXtNwy9eRFDEoNspg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Oct 2013 09:28:56 +0100
Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wrote:

> 2013/10/29 Nathan Hintz <nlhintz@hotmail.com>:
> > On Tue, 29 Oct 2013 07:52:58 +0100
> > Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wrote:
> >
> >> 2013/10/29 Nathan Hintz <nlhintz@hotmail.com>:
> >> > Don't update the slot in "bgmac_dma_rx_skb_for_slot" unless both=
 the
> >> > skb alloc and dma mapping are successful; and free the newly all=
ocated
> >> > skb if a dma mapping error occurs. =20
> >> > returning when an error occurs.
> >>
> >> In case of bgmac_dma_rx_skb_for_slot failure we're giving up anywa=
y
> >> (and freeing everything), but with your patch code is simpler to
> >> understand, so I'm OK with that.
> >>
> >> Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> >>
> >
> > I might be misunderstanding; but it in the case of failure, it appe=
ared to me
> > that the currently received packet was dropped and the old skb woul=
d continue
> > to be assigned to the slot and would be used to receive future pack=
ets (this
> > would continue until bgmac_dma_rx_skb_for_slot was successful).
>=20
> I was commenting on current usage (.), not my WIP patch
> for bgmac_dma_rx_read :)
>=20
> Your patch will be helpful for my bgmac_dma_rx_read rework.
>=20
You're right, I was commenting to you WIP.  The commit message should p=
robably
be changed to remove the statement "This will prevent an skb leak upon =
returning
when an error occurs", as this doesn't occur with the usage in bgmac_dm=
a_alloc.
Unfortunately, I won't be able to send a revised patch until tonight.

Nathan


--=20
Nathan
