From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bonding: send arp requests even if there's
 no route to them
Date: Sun, 02 Mar 2014 14:54:36 -0500 (EST)
Message-ID: <20140302.145436.917231372562996113.davem@davemloft.net>
References: <1393587559-26437-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, f.cachereul@alphalink.fr,
	zhchen@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbaCBTyh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 14:54:37 -0500
In-Reply-To: <1393587559-26437-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Veaceslav Falico <vfalico@redhat.com>
Date: Fri, 28 Feb 2014 12:39:19 +0100

> Currently we're only sending arp requests if we have a route to the t=
arget
> (and, thus, can find out the source ip address).
>=20
> There are some use cases, however, where we don't want/need to set an=
 ip
> address (or set up a specific route) for bonding to use arp monitorin=
g *for
> traffic generation*. We can easily send arp probes (arp requests with=
 src
> ip =3D=3D 0) to generate arp broadcast responses from the target ip a=
nd use
> them for determining if the target is up.
>=20
> This, obviously, won't work with arp validation - because we don't ha=
ve the
> ip address set and, thus, will filter out the responses. So in that c=
ase -
> print a warning.
>=20
> CC: Fran=E7ois CACHEREUL <f.cachereul@alphalink.fr>
> CC: Zhenjie Chen <zhchen@redhat.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thank you.
