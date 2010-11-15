From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: network device reference leak with net-next
Date: Mon, 15 Nov 2010 11:10:24 -0800
Message-ID: <20101115111024.3b3377be@nehalam>
References: <20101115105646.0cc823ce@nehalam>
	<1289847840.2607.120.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42340 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217Ab0KOTKa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 14:10:30 -0500
In-Reply-To: <1289847840.2607.120.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Nov 2010 20:04:00 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 15 novembre 2010 =E0 10:56 -0800, Stephen Hemminger a =E9cri=
t :
> > This is a new regression (doesn't exist with 2.6.36)
> >=20
> > If I shutdown KVM instance with Virt manager, the virtual
> > interfaces in the bridge aren't getting cleaned up because
> > of leftover reference count.
> >=20
> >=20
> > [ 9781.050474] unregister_netdevice: waiting for vnet1 to become fr=
ee. Usage count =3D 1
> > [ 9785.143400] virbr4: port 3(vnet6) entering forwarding state
> > [ 9785.177194] virbr4: port 3(vnet6) entering disabled state
> > [ 9785.201129] device vnet6 left promiscuous mode
> > [ 9785.201135] virbr4: port 3(vnet6) entering disabled state
> > [ 9791.286950] unregister_netdevice: waiting for vnet1 to become fr=
ee. Usage count =3D 1
> > [ 9795.461526] unregister_netdevice: waiting for vnet6 to become fr=
ee. Usage count =3D 1
> > [ 9801.523398] unregister_netdevice: waiting for vnet1 to become fr=
ee. Usage count =3D 1
> > --
>=20
> Is the refcount stay forever to 1, or eventually reaches 0 ?
>=20
>=20
>=20

Stays 1 for as long as I waited about 10 minutes

--=20
