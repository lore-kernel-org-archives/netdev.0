From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] llc: convert the socket list to RCU locking (was
 Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast
 delivery)
Date: Tue, 08 Dec 2009 22:26:19 +0100
Message-ID: <4B1EC47B.9040305@gmail.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <200912040130.54966.opurdila@ixiacom.com> <4B184F4C.3060407@gmail.com> <200912082310.45846.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48132 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966198AbZLHV0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 16:26:20 -0500
In-Reply-To: <200912082310.45846.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
>>
>=20
> OK, here is my first try at llc RCU-fication.=20

Nice work !

>=20
> One doubt before pasting the code: In slab.h comment and in udp.c I s=
ee the lookup is restarted if an improper object is returned. Is that r=
eally required?
>=20


Its needed only if you convert to a hash table (more than one chain),
and I guess you definitly want a fanout of your XXXX items ?

Check Documentation/RCU/rculist_nulls.txt for details :)

