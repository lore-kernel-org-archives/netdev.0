From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly
 increment bsockets and num_owners
Date: Mon, 29 Nov 2010 13:49:55 +0100
Message-ID: <1291034995.3435.345.camel@edumazet-laptop>
References: <20101129123909.GA9286@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Nagendra Tomar <tomer_iisc@yahoo.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62400 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154Ab0K2MuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 07:50:01 -0500
Received: by wwa36 with SMTP id 36so4666434wwa.1
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 04:49:59 -0800 (PST)
In-Reply-To: <20101129123909.GA9286@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 12:39 +0000, Jarek Poplawski a =C3=A9c=
rit :

> Probably I miss something, but since bsockets is increased by each
> passive connection now, it seems it will trigger "hash table is full"
> too early?
>=20

bsockets is the number of bound sockets.

It must be increased for each passive connection, since they are
bound :)

The value of bsockets is used to speedup bind() syscall, if few sockets
are bound. If not, no optimization takes place.



