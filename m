From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2] net: r8169: convert to hw_features
Date: Mon, 11 Apr 2011 15:30:29 +0200
Message-ID: <20110411133029.GA12119@rere.qmqm.pl>
References: <1302277067.19764.2.camel@obelisk.thedillows.org> <20110408163556.D8D1213909@rere.qmqm.pl> <20110410154508.GA17091@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Dillow <dave@thedillows.org>,
	Hayes Wang <hayeswang@realtek.com>
To: =?iso-8859-2?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:49018 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848Ab1DKNab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 09:30:31 -0400
Content-Disposition: inline
In-Reply-To: <20110410154508.GA17091@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 10, 2011 at 05:45:08PM +0200, Fran=E7ois Romieu wrote:
>=20
> On Fri, Apr 08, 2011 at 06:35:56PM +0200, Micha=B3 Miros=B3aw wrote:
> > Simple conversion with a bit of needed cleanup.
> The description should include :
> - Rx VLAN tag stripping is now enabled by default

Actually, it was enabled by default before. NETIF_F_HW_VLAN_TX_RX was
#defined to be NETIF_F_HW_VLAN_TX+NETIF_F_HW_VLAN_RX.

> As far as I understand it, it is fine to have dev->hw_features
> strictly smaller than dev->features, right ?

Yes. hw_features signifies what can be toggled by user, but does not
imply state of features not present there.

Best Regards,
Micha=B3 Miros=B3aw
