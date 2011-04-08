From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] net: r8169: convert to hw_features
Date: Fri, 08 Apr 2011 11:37:47 -0400
Message-ID: <1302277067.19764.2.camel@obelisk.thedillows.org>
References: <20110408123847.64FF813A64@rere.qmqm.pl>
	 <20110408124406.GA22478@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amavis-outgoing1.knology.net ([24.214.64.230]:49174 "EHLO
	amavis-outgoing1.knology.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752630Ab1DHPzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 11:55:49 -0400
In-Reply-To: <20110408124406.GA22478@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-08 at 14:44 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Fri, Apr 08, 2011 at 02:38:46PM +0200, Micha=C5=82 Miros=C5=82aw w=
rote:
> > This enables SG+IP_CSUM+TSO by default (there were no comments sugg=
esting
> > leaving them out was intentional).
> >=20
> > This also fixes confusion around vlan_features in rtl8169_vlan_mode=
().
>=20
> BTW, I noticed that TSO will break for MTU > 4095+(TCP+IP header len)=
=2E
> This needs handing in ndo_fix_features callback like other MTU-limite=
d TSO
> engines.

I'd suggest leaving SG/CSUM/TSO off by default -- I played with getting
them working some time ago, and IIRC the current code doesn't handle al=
l
devices properly. Add the issue you note above and you are knowingly
leaving landmines laying about for users of a popular piece of hardware=
=2E

Realtek, Francois, please correct me if I'm mistaken.

Dave

