From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rfs: Receive Flow Steering
Date: Tue, 06 Apr 2010 17:10:52 +0200
Message-ID: <1270566652.2081.38.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004052248390.29212@pokey.mtv.corp.google.com>
	 <1270559096.2081.35.camel@edumazet-laptop>
	 <v2n65634d661004060725paf401b5bg1ee692caef565d33@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:55781 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab0DFPK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 11:10:59 -0400
Received: by bwz1 with SMTP id 1so3710054bwz.21
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 08:10:56 -0700 (PDT)
In-Reply-To: <v2n65634d661004060725paf401b5bg1ee692caef565d33@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 avril 2010 =C3=A0 07:25 -0700, Tom Herbert a =C3=A9crit :

> > 2) inet_rps_save_rxhash(sk, skb->rxhash);
> >
> >        It should have a check to make sure some part of the stack d=
oesnt feed
> > many different rxhash for a given socket (Make sure we dont pollute=
 flow
> > table with pseudo random values)
> >
> If packets for a connection are always received on the same device, i=
s
> it reasonable to assume the rxhash is constant for that connection?
>=20
> I suppose it's possible that packets for a same sockets are being
> constantly received on two different devices that are giving differen=
t
> rxhashes.  This would already be bad in that OOO is probably happenin=
g
> anyway.  I don't know if thrashing the sock_flow_table is going to
> aggravate this scenario much.
>=20
> Are there any other degenerative cases you're worried about?

No, I was only considering this mostly as a debugging aid, before RPS i=
s
stable, because mismatches could be unnoticed and performance not
optimal.
=20


