From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bugzilla 42595
Date: Wed, 18 Jan 2012 15:42:06 +0100
Message-ID: <1326897726.2316.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F15D417.4050005@fud.no> <1326843827.2606.35.camel@edumazet-laptop>
	 <1326884311.2316.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1326894249.2316.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <8a6ad9cfd5afefc5617fc82203712f20@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37811 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757705Ab2AROmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 09:42:10 -0500
Received: by bkas6 with SMTP id s6so2825490bka.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 06:42:09 -0800 (PST)
In-Reply-To: <8a6ad9cfd5afefc5617fc82203712f20@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 15:20 +0100, Tore Anderson a =C3=A9c=
rit :
> * Eric Dumazet
>=20
> > Following patch seems to help for me, please test it ;)
>=20
> Looks very good! I uploaded a PCAP to the bug report:
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42595#c7
>=20

Thanks

It seems that if you try to have the default ethtool settings (tso, gso=
,
tx checksum ... on), transfert is very slow... I am investigating, but =
I
suspect that if dst_allfrag() is true, we must disable gso as well.
