From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] bonding: convert to ndo_fix_features
Date: Sat, 7 May 2011 09:37:27 +0200
Message-ID: <20110507073727.GA4522@rere.qmqm.pl>
References: <20110506175629.BC59D1389B@rere.qmqm.pl>
 <5525.1304705884@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60531 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab1EGHh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 03:37:29 -0400
Content-Disposition: inline
In-Reply-To: <5525.1304705884@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2011 at 11:18:04AM -0700, Jay Vosburgh wrote:
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> >This should also fix updating of vlan_features and propagating chang=
es to
> >VLAN devices on the bond.
> >
> >Side effect: it allows user to force-disable some offloads on the bo=
nd
> >interface.
> >
> >Note: NETIF_F_VLAN_CHALLENGED is managed by bond_fix_features() now.
> >
> >BTW, What are the problems in creating VLAN devices on an empty bond
> >(as stated in one of bond_setup() comments)?
> 	If there are no slaves, then the bond does not have a MAC
> address assigned (because it gets its initial MAC from the first slav=
e).
> It's therefore impossible to pass a MAC address up to the VLAN
> interface.
>=20
> 	So the limitation is that the bond must have at least one slave
> before a VLAN may be configured above it.

Hmm. That might be worked aroud by generating random MAC then. This wou=
ld
allow the user to first set a new MAC, create VLANs and then add slaves
when they show up.

Best Regards,
Micha=B3 Miros=B3aw
