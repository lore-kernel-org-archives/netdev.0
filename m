From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems obtaining software TX timestamps
Date: Wed, 08 Sep 2010 17:12:51 +0200
Message-ID: <1283958771.2748.85.camel@edumazet-laptop>
References: <4C877D8A.6040002@edu.uni-klu.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ingo Kofler <ikofler@edu.uni-klu.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56701 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab0IHPMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 11:12:55 -0400
Received: by fxm16 with SMTP id 16so136314fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 08:12:54 -0700 (PDT)
In-Reply-To: <4C877D8A.6040002@edu.uni-klu.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 septembre 2010 =C3=A0 14:11 +0200, Ingo Kofler a =C3=A9c=
rit :
> Dear all,
>=20
> I am trying to obtain software TX timestamps for a each outgoing pack=
et=20
> of an UDP socket. For that purpose I set the SO_TIMESTAMPING socket=20
> option to SOF_TIMESTAMPING_TX_SOFTWARE | SOF_TIMESTAMPING_SOFTWARE. T=
he=20
> setsockopt call succeeds and also a subsequent getsockopt returns the=
=20
> correct flags. However, if a send a single datagram over the socket a=
nd=20
> try to fetch the packet as well as its timestamp via the socket's=20
> MSG_ERRQUEUE I do not get any information. Rather, the select call wa=
its=20
> infinitely on the error queue....
>=20
> I hardly found any documentation on this timestamping mechanism excep=
t=20
> the text file in the kernel source code. All I've figured out is that=
 if=20
> I want to have hardware TX timestamps, I'll have to make a further io=
ctl=20
> which requires root permissions to active the hardware timestamping. =
But=20
> this is not what I want... software timestamps are sufficient for me.=
=20

To my knowledge, no driver calls skb_tx_timestamp()

You'll need to tweak your NIC driver to play with this TX timestamps


