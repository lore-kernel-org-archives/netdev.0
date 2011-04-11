From: =?utf-8?B?RnJhbsOnb2lz?= Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] net: r8169: convert to hw_features
Date: Mon, 11 Apr 2011 20:47:39 +0200
Message-ID: <20110411184739.GA17331@electric-eye.fr.zoreil.com>
References: <1302277067.19764.2.camel@obelisk.thedillows.org> <20110408163556.D8D1213909@rere.qmqm.pl> <20110410154508.GA17091@electric-eye.fr.zoreil.com> <20110411133029.GA12119@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Dillow <dave@thedillows.org>,
	Hayes Wang <hayeswang@realtek.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56055 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370Ab1DKS4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 14:56:31 -0400
Content-Disposition: inline
In-Reply-To: <20110411133029.GA12119@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2011 at 03:30:29PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> On Sun, Apr 10, 2011 at 05:45:08PM +0200, Fran=C3=A7ois Romieu wrote:
[...]
> > The description should include :
> > - Rx VLAN tag stripping is now enabled by default
>=20
> Actually, it was enabled by default before. NETIF_F_HW_VLAN_TX_RX was
> #defined to be NETIF_F_HW_VLAN_TX+NETIF_F_HW_VLAN_RX.

It was enabled in dev->features but it was necessary to configure at
least one VLAN before the hardware CPlusCmd register was instructed
to strip Rx vlan tag (let aside 8110SCd or tagged Tx packets which
where sent as such).

I am not sure it will be noticed.

[...]
> Yes. hw_features signifies what can be toggled by user, but does not
> imply state of features not present there.

Thanks for the clarification.

On a different topic, David was right. The large send feature needs
more fixing. I should have a first tested patch for wednesday.

Hayes, I have a 8168c manual at hand. Do all 8168 have the same Tx
descriptors layout ?

--=20
Ueimor
