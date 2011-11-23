From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Wed, 23 Nov 2011 07:09:00 +0100
Message-ID: <1322028540.1298.8.camel@edumazet-laptop>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
	 <CABrhC0m75OHmdDD-crr=tvTiRq_hnh7WpHtLjM9TKgTa24MSOA@mail.gmail.com>
	 <1322025880.29324.1.camel@edumazet-laptop>
	 <1322027911.1298.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Young <jlyo@jlyo.org>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56460 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756421Ab1KWGJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 01:09:06 -0500
Received: by bke11 with SMTP id 11so1187190bke.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 22:09:04 -0800 (PST)
In-Reply-To: <1322027911.1298.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 novembre 2011 =C3=A0 06:58 +0100, Eric Dumazet a =C3=A9c=
rit :

> First connection went well.
>=20
> Now we try to reuse tuple  (ports 49374, 8009 on loopback) while a so=
cket is in TIMEWAIT, and first
> SYN packet (time 06:48:20.337335) is dropped (considered as a packet =
part of previous session)
>=20
> Now why the first SYN packet is dropped and not the second one, I don=
t know yet.


in netstat -s output, the suspect increasing counter is :

"45 congestion windows recovered without slow start after partial ack"
