From: Li Yu <raise.sail@gmail.com>
Subject: Re: A possible bug in reqsk_queue_hash_req()
Date: Wed, 21 Apr 2010 10:02:02 +0800
Message-ID: <4BCE5C9A.3080805@gmail.com>
References: <i2x9b948ee41004200335vc229a59cvc0a08c35c949d7dd@mail.gmail.com>	 <1271761611.3845.223.camel@edumazet-laptop>	 <u2m9b948ee41004200621zf829996y813c37c5f6a3691f@mail.gmail.com> <1271775681.7895.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:43736 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754714Ab0DUCCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 22:02:11 -0400
In-Reply-To: <1271775681.7895.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet =E5=86=99=E9=81=93:
> Le mardi 20 avril 2010 =C3=A0 21:21 +0800, Li Yu a =C3=A9crit :
>=20
>> In my word, write lock also means mutual exclusion among all writers=
,
>> is it right?
>>
>=20
> Yes, generally speaking.
>=20
> But not on this use case.
>=20
> This is documented in an include file, if you search for syn_wait_loc=
k
>=20
>>> All callers of this reqsk_queue_hash_req() must have the socket loc=
ked
>> See. If we always assumed the caller should hold the locked socket
>> first, this is not a bug, but I think we'd better add a comment at
>> header file.
>=20
> It is documented, as a matter of fact :)
>=20
>=20

Great, this isn't a bug, you are right here :)

I just found out these comments about syn_wait_lock, it seem that we ne=
ed to crossed reference documents for kernel API, a newbie like me, may=
 confused at such similar problems.


>=20
