From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 13:56:46 -0700 (PDT)
Message-ID: <20070711.135646.115909857.davem@davemloft.net>
References: <OF12E7973A.D9D0F9C5-ON88257315.005882D0-88257315.0058D5B9@us.ibm.com>
	<200707111919.11746@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dlstevens@us.ibm.com, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: rdenis@simphalempin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758161AbXGKU4X convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 16:56:23 -0400
In-Reply-To: <200707111919.11746@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: R=E9mi_Denis-Courmont <rdenis@simphalempin.com>
Date: Wed, 11 Jul 2007 19:19:11 +0300

> Le mercredi 11 juillet 2007, David Stevens a =E9crit :
> >         That sounds like a good idea to me (FWIW),
> > though I also still think a simple raw-socket
> > application would do it just fine, possibly with
> > no kernel modification at all.
> >         But since the kernel wouldn't be maintaining
> > the DNS info, which was my real objection to the
> > original version,  netlink would work well too.
>=20
> One remaining corner case is NFS/IPv6 root, whereby userland won't ha=
ve=20
> a chance to start before the network, and hence may miss the solicite=
d=20
> RA. Or would it? By default, the next unsolicited RA can be anytime=20
> from now to after 10 minutes, so that's not sufficient. I wouldn't=20
> personnaly care, but...

We already have cases like that with network device firmware that
has to be loaded in from the filesystem in userspace, and the
answer is to use a properly populated initrd.

Same goes for things like this.

That's the fact of life these days, like it or not.

