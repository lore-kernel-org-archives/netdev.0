From: Simon Schubert <2@0x2c.org>
Subject: Re: BUG in skb_dequeue (skb->next is NULL)
Date: Wed, 01 Dec 2010 11:34:36 +0100
Message-ID: <4CF624BC.8030409@0x2c.org>
References: <alpine.LNX.2.00.1011071631550.2636@dyndns.pervalidus.net>	 <loom.20101201T095252-592@post.gmane.org> <1291199299.2856.499.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig64F50417063CB7426BAB8271"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291199299.2856.499.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig64F50417063CB7426BAB8271
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/01/2010 11:28 AM, Eric Dumazet wrote:
> Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 09:02 +0000, Simon Schubert a =
=C3=A9crit :
>> Fr=C3=A9d=C3=A9ric L. W. Meunier <2 <at> pervalidus.net> writes:
>=20
> CC netdev
>> RIP: 0010:[<ffffffff81459069>]  [<ffffffff81459069>] skb_dequeue+0x59/=
0x90
>> Call Trace:
>>  [<ffffffff814ef0fa>] unix_stream_recvmsg+0x1aa/0x790
>>  [<ffffffff8145124d>] sock_recvmsg+0xfd/0x130
>>  [<ffffffff81155fd0>] ? pollwake+0x0/0x60
>>  [<ffffffff81452b54>] __sys_recvmsg+0x144/0x2e0
>>  [<ffffffff81155fd0>] ? pollwake+0x0/0x60
>>  [<ffffffff8104d88a>] ? finish_task_switch+0x4a/0xd0
>>  [<ffffffff8154fa91>] ? schedule+0x411/0xa50
>>  [<ffffffff81452f99>] sys_recvmsg+0x49/0x80
>>  [<ffffffff8100b0b2>] system_call_fastpath+0x16/0x1b
>=20
> Is it reproductible ?

I can't trigger it on purpose, but it happened two nights in a row (I
don't have the previous backtrace though)

> On previous kernel (say 2.6.35) you never hit this bug ?

No.

cheers
  simon


--------------enig64F50417063CB7426BAB8271
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBAgAGBQJM9iTBAAoJEO/hP/rC6EwxDEEQAKFnCRxGTGTu/WTUBLPiJHoQ
eID/ft/ZVg0NxFNwjBDQfGhpnuhFsKBGgt17CNvTlWFWZnNkhofjyoETRoqZGON9
BZrPwGjxEvznMf1L6cmqyP4v4d4dFiDTsgFWKzs9rN2F1YRDyMbX96zTsx75Gbs8
yrr8pBRJaAeodD7wGLbR0tvc14Dbep3TRaptxAW+I5C2EkxInwrguix6/mx+chab
Dl3K+jkk8tX3oKRtsu52DTuweR0QciWuXKd1lZJwTRbQEmrqUp422yX/qa8LjKAg
1O2v5IQr+NDNPtWMnYCxJuGIFRajTPJLRlx52CK/AHx4040BksLjF+rTaa2Cj4GI
npcZ+TG8mmhWrImMeVhkSWOofdAiYeuNP7LIGqFNZpRByP08w3KzlLaWT6UEF2Tg
V5BVcnb5UTo8fzSWFe4TcaTb9H1Rrngkmvv89+Rjzy4lMhlSn7wdZHS/jxm2u5WF
rknmaiUx2F+8NuT67FQa+QJkIU6XBtWlgQpsvqoJvVOJrnbs7j/MW1V2bp9nXDv3
X+ugmLZiQas1gcr7tmLV13OetXu816RiFsGvKb7PaxkVYx2tI2cBRB55QZfIWWdT
3whgt1nGm6JBUZlXJNMB1fG+h72fVQC51RXO6ptJe7uQUKwE9rgWjxOhgpoma8PT
U6BXsgcI6962wV7F+6ZI
=8BTF
-----END PGP SIGNATURE-----

--------------enig64F50417063CB7426BAB8271--
