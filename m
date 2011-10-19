From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 15:27:09 +0200
Message-ID: <1319030829.8416.15.camel@edumazet-laptop>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4) <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319030503.8416.11.camel@edumazet-laptop>
	 (sfid-20111019_152225_494986_6CAEF901) <1319030738.4424.39.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59771 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833Ab1JSN1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 09:27:14 -0400
Received: by bkbzt19 with SMTP id zt19so2113337bkb.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 06:27:13 -0700 (PDT)
In-Reply-To: <1319030738.4424.39.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 15:25 +0200, Johannes Berg a =C3=A9c=
rit :

> Well, yeah, ok, but Richard's patches do modify sk_refcnt, and can't
> modify sk_wmem_alloc as discussed upthread.
>=20
> I'll admit that I don't really trust the whole thing anyway -- it see=
ms
> rather error prone to forbid you from doing sock_hold() on a socket y=
ou
> obtained from a TX packet.
>=20

I probably missed why sk_wmem_alloc can not be modified ?
