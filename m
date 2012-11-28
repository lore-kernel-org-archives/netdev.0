From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: move inet_dport/inet_num in
 sock_common
Date: Wed, 28 Nov 2012 09:18:45 -0800
Message-ID: <1354123125.14302.432.camel@edumazet-glaptop>
References: <1354102061.14302.84.camel@edumazet-glaptop>
	 <1354107378.14302.149.camel@edumazet-glaptop>
	 <20121128.114835.1005932954047935079.davem@davemloft.net>
	 <20121128.120243.1053933388686939425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ling.ma.program@gmail.com, joe@perches.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:44472 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab2K1RSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:18:48 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so10479436iea.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 09:18:48 -0800 (PST)
In-Reply-To: <20121128.120243.1053933388686939425.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 12:02 -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 28 Nov 2012 11:48:35 -0500 (EST)
>=20
> > I like this a lot, applied, thanks Eric!
>=20
> And I'd like it even more if it was build tested :-/
>=20
> net/ipv4/inet_hashtables.c: In function =E2=80=98__inet_lookup_establ=
ished=E2=80=99:
> net/ipv4/inet_hashtables.c:242:7: error: expected expression before =E2=
=80=98)=E2=80=99 token
> net/ipv4/inet_hashtables.c:246:8: error: expected expression before =E2=
=80=98)=E2=80=99 token
> net/ipv4/inet_hashtables.c:267:7: error: expected expression before =E2=
=80=98)=E2=80=99 token
> net/ipv4/inet_hashtables.c:274:8: error: expected expression before =E2=
=80=98)=E2=80=99 token
> net/ipv4/inet_hashtables.c:226:2: warning: unused variable =E2=80=98a=
cookie=E2=80=99 [-Wunused-variable]
> net/ipv4/inet_hashtables.c: In function =E2=80=98__inet_check_establi=
shed=E2=80=99:
> net/ipv4/inet_hashtables.c:326:7: error: expected expression before =E2=
=80=98)=E2=80=99 token
> net/ipv4/inet_hashtables.c:341:7: error: expected expression before =E2=
=80=98)=E2=80=99 token
> net/ipv4/inet_hashtables.c:307:2: warning: unused variable =E2=80=98a=
cookie=E2=80=99 [-Wunused-variable]
> net/ipv4/inet_hashtables.c:306:6: warning: unused variable =E2=80=98d=
if=E2=80=99 [-Wunused-variable]
>=20
> This is with gcc-4.7.2-2 on Fedora 17 on an allmodconfig build.

Hmm, sorry David, I'll double check and send a v3.

Thanks
