From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT]: Networking
Date: Sat, 12 Dec 2009 11:49:12 +0100
Message-ID: <4B237528.8020708@gmail.com>
References: <20091211.181712.211179737.davem@davemloft.net> <4B236C18.4050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54453 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbZLLKtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 05:49:16 -0500
In-Reply-To: <4B236C18.4050007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2009 11:10, William Allen Simpson a =C3=A9crit :
> David Miller wrote:
>> David S. Miller (4):
>>       Merge branch 'master' of
>> git://git.kernel.org/.../linville/wireless-next-2.6
>>       tcp: Remove runtime check that can never be true.
>=20
> This is a poor patch that was never sent to the netdev list for revie=
w.=20
> Copies to
> and from user space should always check for buffer overruns.  A bette=
r
> patch was
> submitted (attached) some time ago.
>=20
> Miller's patch has 2 flaws:
>=20
>  1) It accidentally removed a comment line that describes the purpose=
 of
> the
> following memcpy(), paralleling language in the internet-draft.
>=20
>  2) It fails to test for buffer overruns.  The existing code has an
> accurate test,
> that compiles (to no code) correctly with current gcc.  But it produc=
es
> a warning
> in some (fairly old) gcc versions.
>=20
> Instead, the better patch uses the Kernel defined BUILD_BUG_ON().  Pl=
ease
> substitute the better patch in the main tree.
>=20
>=20
>>       Merge branch 'master' of
>> git://git.kernel.org/.../linville/wireless-2.6
>>       Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
>>

William, as I already said, you wont solve your problem with David
alerting whole earth, Linus, God, whoever, because we dont care,
we have our own problems.

This drama is really ridiculous, could we go forward, correct bugs,
add documentation, and so on ?

If you really want this BUILD_BUG_ON() (because some dev could
introduce a bug changing TCP_COOKIE_PAIR_SIZE or TCP_MSS_DEFAULT (???)
in the future, without David or other network dev noticing this),
please submit a _normal_ patch against net-2.6 and through David Miller=
,
the official network maintainer, your best friend for network patches.

