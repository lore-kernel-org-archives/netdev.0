From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 09:00:14 +0200
Message-ID: <1309849214.2720.45.camel@edumazet-laptop>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	 <1309846875.2720.43.camel@edumazet-laptop>  <4E12B5A6.2020802@inliniac.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Victor Julien <victor@inliniac.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54150 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775Ab1GEHAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 03:00:19 -0400
Received: by wwe5 with SMTP id 5so5625826wwe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 00:00:17 -0700 (PDT)
In-Reply-To: <4E12B5A6.2020802@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 08:56 +0200, Victor Julien a =C3=A9crit=
 :

> Is this still also true for IP fragments?
>=20

This point was already raised. IP fragments have rxhash =3D 0, obviousl=
y,
since we dont have full information (source / destination ports for
example)



