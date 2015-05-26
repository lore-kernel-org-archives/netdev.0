From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 26 May 2015 13:46:36 -0400
Message-ID: <1432662396.28905.157.camel@redhat.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	 <1432647280.28905.107.camel@redhat.com>
	 <20150526165928.GC11800@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-9sFUD7FrFbaf1XN+erhX"
Cc: Haggai Eran <haggaie@mellanox.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbbEZRqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 13:46:48 -0400
In-Reply-To: <20150526165928.GC11800@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9sFUD7FrFbaf1XN+erhX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-05-26 at 10:59 -0600, Jason Gunthorpe wrote:
> On Tue, May 26, 2015 at 09:34:40AM -0400, Doug Ledford wrote:
>=20
> > This is a core feature more than anything else.  Namespaces for RDMA
> > devices is not unique to IB or RoCE in any way.  Yet no thought has bee=
n
> > given to how this will work universally across all of the RDMA
> > capable
>=20
> I think if Haggi is able to follow the perscription I gave then things
> will be general.
>=20
>  - All rdma cm ids are associated with a netdev
>  - The output flow uses that netdev to restrict, configure and
>    determine the output RDMA device QP
>  - The input flow locates the netdev as step one and then uses the
>    (netdev,ip,port) tuple to find the rdma listener, which is in turn
>    tied to a netdev and is restricted/configured by it.
>=20
> The technology specific part is the two maps: from (input
> device,packet) to netdev, from netdev to (output device,packet)
>=20
> After the above clean up is done, namespace enabling is basically
> providing those two mapping functions for each technology in a way
> that can locate delegatable netdevs.
>=20
> The trivial case for all the ethernet techs is to provide the above
> maps that can take the (input device,VLAN) and locate the correct
> child VLAN specific netdev. The existing code to support VLAN should
> pretty much immediately enable basic namespace support for all the
> ethernet families.
>=20
> The big open question for ethernet is how to work without relying on
> VLAN to create delgated netdevs - typically one would use a bridge and
> veth's, which do not seem very RDMA compatible. But that doesn't need
> to be answered right now.
>=20
> Remember, this isn't RDMA namespaces, this is netdev namespace support
> for RDMA-CM -> very different things.

That was the point of my email.  This is a very myopic view of the
feature.  It *should* at least have an idea of these other things too.

> Basically, I'm happy with the generality story, if the clean up work I
> outlined turns out..
>=20
> > issue for usNIC as if you want namespace support there, you just start
> > the user space app in a given namespace and you are probably 90% of
> > the
>=20
> usNIC has no kernel facing functionality, and no interaction with
> RDMA-CM, so it is irrelevant to any discussion about RDMA-CM :(

Whether usNIC has a kernel facing functionality or not is irrelevant.
This feature isn't kernel only, it effects user space applications
launched in a namespace too.  And, again, my point was that this
discussion is about RDMA-CM and it should be broader (even if the
implementation isn't broader).  Due to the implementation of usNIC I
suspect it would "just work", but it would be better to know so.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD


--=-9sFUD7FrFbaf1XN+erhX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVZLF8AAoJELgmozMOVy/dSK0P/1Fbwdlp35TkHKJS0/hSVVpF
GeEoNSbS2xmCJxmozPArCO5/HN1MKZK3JZLEsIAtyd9pAw+FOLiHMHRSREBJRq2e
HaX/+yNbSuZL+zBj4ueNN8V8NolzxH9TBulNTZvJAlv5GpzLxhV/n9FNTcloaDE/
piSuqTrKvA2sRnIPqN1H8alO6FmaaH3BWev8zZLON66jGrYx6aMVa6a+IStJ8uB4
iIDkvx+2Xfn2sWPmQvQsXv2/gkNp/31TzhAfS424Bh66B1MhcU2rfoB5WXOI6Zwa
3DBBUYyB6jnivAStf3O8Hy4vgpt3oU5Fkn13U3JLjritZzL3C9H07NDqdi0sZJ6f
k9nKSWANCenpo7DVqPjbmDs1RO7EpCha5ttw6KUcziTjw73Sg4JrjhmaAyBnTuog
qsJ2Ckhyx808Mouo/fkNhoVOuvCdag4/dXFPI8nFB8rwITnXu5kqcJMW4oEqYiIP
+ZqWiHLKfA9efADZITnmGJlov8eTXcEtCHtfG2DZPqS0gPIu00roYz3SwFQB45KG
yRGrWZHdiQme/3dCiUl/t46kvE9P44Ys9+gF694FxFUipOwTkHapegFBRZlnqNkQ
h9Dm0USltdON/3966h83KELpwzXoeoQQDM2m3WJ4Ic1cJQ2oHwJLhC3ivfdqk2oh
epMBZ918TzF0lL7kqTLt
=0MEv
-----END PGP SIGNATURE-----

--=-9sFUD7FrFbaf1XN+erhX--
