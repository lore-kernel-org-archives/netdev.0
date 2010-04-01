From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: add support for htonb and ntohb
Date: Thu, 01 Apr 2010 22:47:34 +0200
Message-ID: <1270154854.2192.3.camel@edumazet-laptop>
References: <20100401203209.GC28741@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:63675 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab0DAUri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 16:47:38 -0400
Received: by bwz1 with SMTP id 1so1154174bwz.21
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 13:47:37 -0700 (PDT)
In-Reply-To: <20100401203209.GC28741@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 16:32 -0400, Andy Gospodarek a =C3=A9crit=
 :
> After my recent post to net-2.6 this week to accidentally run htons t=
o a
> u8, it is clear to me we _must_ add some infrastructure to make sure
> single bytes are in the correct network and host order on big and lit=
tle
> endian systems.  Today seemed like the perfect day to post this.
>=20
> This patch adds basic support for htonb and ntohb.  Patches to add th=
is
> in the entire networking tree in _every_ case where a single byte is
> accessed will be posted next week -- I'm almost done with them!
>=20
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---

Seems fine, thanks a lot Andy.

Hmm, I notice this doesnt handle yet arches where a byte is 9 bits long=
=2E

Do you have any plan, to finally support PDP-6/10 ?



