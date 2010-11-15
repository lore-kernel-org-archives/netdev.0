From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network device reference leak with net-next
Date: Mon, 15 Nov 2010 20:04:00 +0100
Message-ID: <1289847840.2607.120.camel@edumazet-laptop>
References: <20101115105646.0cc823ce@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46270 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932703Ab0KOTET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 14:04:19 -0500
Received: by eye27 with SMTP id 27so3127174eye.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 11:04:17 -0800 (PST)
In-Reply-To: <20101115105646.0cc823ce@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 novembre 2010 =C3=A0 10:56 -0800, Stephen Hemminger a =C3=A9=
crit :
> This is a new regression (doesn't exist with 2.6.36)
>=20
> If I shutdown KVM instance with Virt manager, the virtual
> interfaces in the bridge aren't getting cleaned up because
> of leftover reference count.
>=20
>=20
> [ 9781.050474] unregister_netdevice: waiting for vnet1 to become free=
=2E Usage count =3D 1
> [ 9785.143400] virbr4: port 3(vnet6) entering forwarding state
> [ 9785.177194] virbr4: port 3(vnet6) entering disabled state
> [ 9785.201129] device vnet6 left promiscuous mode
> [ 9785.201135] virbr4: port 3(vnet6) entering disabled state
> [ 9791.286950] unregister_netdevice: waiting for vnet1 to become free=
=2E Usage count =3D 1
> [ 9795.461526] unregister_netdevice: waiting for vnet6 to become free=
=2E Usage count =3D 1
> [ 9801.523398] unregister_netdevice: waiting for vnet1 to become free=
=2E Usage count =3D 1
> --

Is the refcount stay forever to 1, or eventually reaches 0 ?



