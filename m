From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: 2.6.23-mm1 s390 driver problem
Date: Fri, 19 Oct 2007 13:25:29 +0200
Message-ID: <1192793129.25150.12.camel@localhost>
References: <20071018200148.GA14234@vino.hallyn.com>
	 <200710182215.56428.borntraeger@de.ibm.com>
	 <20071018203151.GA15382@vino.hallyn.com>
	 <1192780036.25150.7.camel@localhost> <471875E0.8040308@fr.ibm.com>
	 <20071019022719.537ee71f.akpm@linux-foundation.org>
	 <47189242.8090006@fr.ibm.com>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linux-kernel@vger.kernel.org, cornelia.huck@de.ibm.com,
	heiko.carstens@de.ibm.com, sam@ravnborg.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:62261 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677AbXJSLZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 07:25:32 -0400
In-Reply-To: <47189242.8090006@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-10-19 at 13:17 +0200, Cedric Le Goater wrote:
> > please cc netdev on network issues.
>=20
> yes.
>=20
> >> Bringing up interface eth0:  ------------=DD cut here =A8---------=
---=20
> >> Kernel BUG at 0000000000000002 =DDverbose debug info unavailable=A8=
=20
> >> illegal operation: 0001 =DD#1=A8=20
> >=20
> > that's a network issue ;)
> >=20
> >> 00000000002b3352 gives : include/linux/netdevice.h:819
> >>
> >=20
> > I have a feeling that we fixed this.  But there's no BUG at 2.6.23-=
mm1's
> > include/linux/netdevice.h:819. =20
>=20
> but dev->header_ops is bogus. right ?
>=20
> > How about setting CONFIG_DEBUG_BUGVERBOSE=3Dy?
>=20
> it is set :(

This is definitly a problem with the header_ops in the qeth network
driver. I've asked our network team to take care of it. Stay tuned..

--=20
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


