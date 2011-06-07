From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: prevent information leak
Date: Tue, 07 Jun 2011 07:41:31 +0200
Message-ID: <1307425291.2642.66.camel@edumazet-laptop>
References: <1307422939.2642.57.camel@edumazet-laptop>
	 <20110606.222416.1114593259198630297.davem@davemloft.net>
	 <1307425119.2642.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44132 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab1FGFlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:41:36 -0400
Received: by wwa36 with SMTP id 36so4537079wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 22:41:35 -0700 (PDT)
In-Reply-To: <1307425119.2642.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 juin 2011 =C3=A0 07:38 +0200, Eric Dumazet a =C3=A9crit :

> It should not matter for these structures, or 393e52e33c6c2 would hav=
e
> break applications on all arches (not only ARM), since it enlarged th=
em
> without any warning ;)
>=20
>=20
>=20

BTW, it means that next time we want to add a field in these structure,
we cant use the padding space, or else an application cant know for sur=
e
if the kernel put a padding (say on linux-3.0) or the new field
(linux-3.8)



