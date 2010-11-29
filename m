From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inet_hash_connect: source port allocation
Date: Mon, 29 Nov 2010 18:26:00 +0100
Message-ID: <1291051560.3435.1198.camel@edumazet-laptop>
References: <4CF3DD02.90906@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: John Haxby <john.haxby@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64731 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755306Ab0K2R0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 12:26:04 -0500
Received: by wyb28 with SMTP id 28so4656474wyb.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 09:26:03 -0800 (PST)
In-Reply-To: <4CF3DD02.90906@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 17:04 +0000, John Haxby a =C3=A9crit :
> Hello,
>=20
> Please forgive me if this is a stupid question, but is there any=20
> particular reason why the source port allocation in=20
> __inet_hash_connect() shouldn't use the same random allocation that=20
> inet_csk_get_port() uses?  The latter, of course, is used when bind()=
=20
> doesn't specify a source port but the implicit "bind" for a connect()=
=20
> gets its port allocated by __inet_hash_connect().
>=20
> jch

autobind vs bind

bind() gives more information, like local address (if any)

autobind(), we dont know local address, it'll be chose later by routing=
=2E



