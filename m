From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2] net: r8169: convert to hw_features
Date: Mon, 11 Apr 2011 21:15:13 +0200
Message-ID: <20110411191513.GB31338@rere.qmqm.pl>
References: <1302277067.19764.2.camel@obelisk.thedillows.org> <20110408163556.D8D1213909@rere.qmqm.pl> <20110410154508.GA17091@electric-eye.fr.zoreil.com> <20110411133029.GA12119@rere.qmqm.pl> <20110411184739.GA17331@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Dillow <dave@thedillows.org>,
	Hayes Wang <hayeswang@realtek.com>
To: =?iso-8859-2?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50851 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461Ab1DKTPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 15:15:14 -0400
Content-Disposition: inline
In-Reply-To: <20110411184739.GA17331@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2011 at 08:47:39PM +0200, Fran=E7ois Romieu wrote:
> On Mon, Apr 11, 2011 at 03:30:29PM +0200, Micha=B3 Miros=B3aw wrote:
> > On Sun, Apr 10, 2011 at 05:45:08PM +0200, Fran=E7ois Romieu wrote:
> [...]
> > > The description should include :
> > > - Rx VLAN tag stripping is now enabled by default
> > Actually, it was enabled by default before. NETIF_F_HW_VLAN_TX_RX w=
as
> > #defined to be NETIF_F_HW_VLAN_TX+NETIF_F_HW_VLAN_RX.
> It was enabled in dev->features but it was necessary to configure at
> least one VLAN before the hardware CPlusCmd register was instructed
> to strip Rx vlan tag (let aside 8110SCd or tagged Tx packets which
> where sent as such).

Are you sure? rtl8169_vlan_mode() that configured this before was
called from rtl8169_init_one(). The change is that this logic was
merged with enabling RX csum offload in rtl8169_set_features().

Best Regards,
Micha=B3 Miros=B3aw
