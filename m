From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sk_add_backlog() take rmem_alloc
 into account
Date: Wed, 28 Apr 2010 00:19:53 +0200
Message-ID: <1272406793.2343.28.camel@edumazet-laptop>
References: <1272389872.2295.405.camel@edumazet-laptop>
	 <1272399662.2343.12.camel@edumazet-laptop>
	 <20100427.144307.22037530.davem@davemloft.net>
	 <20100427.151103.146348463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bmb@athenacr.com, therbert@google.com, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36692 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757308Ab0D0WT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:19:58 -0400
Received: by bwz19 with SMTP id 19so68378bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 15:19:57 -0700 (PDT)
In-Reply-To: <20100427.151103.146348463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 15:11 -0700, David Miller a =C3=A9crit :
> From: David Miller <davem@davemloft.net>
> Date: Tue, 27 Apr 2010 14:43:07 -0700 (PDT)
>=20
> > This looks great, applied, thanks Eric!
>=20
> I have to fix this one up, for example SCTP stopped building because =
it
> still refers to the ->limit member you removed.
> --

Hmm, sorry for this, thanks !


