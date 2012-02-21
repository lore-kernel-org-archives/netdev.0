From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] sock: Introduce the SO_PEEK_OFF sock option
Date: Tue, 21 Feb 2012 15:05:31 -0500 (EST)
Message-ID: <20120221.150531.8578951206190289.davem@davemloft.net>
References: <4F43D49E.3010401@parallels.com>
	<4F43D4F6.6030104@parallels.com>
	<1329846350.18384.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477Ab2BUUFh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:05:37 -0500
In-Reply-To: <1329846350.18384.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 18:45:50 +0100

> Le mardi 21 f=E9vrier 2012 =E0 21:31 +0400, Pavel Emelyanov a =E9crit=
 :
>> This one specifies where to start MSG_PEEK-ing queue data from. When
>> set to negative value means that MSG_PEEK works as ususally -- peeks
>> from the head of the queue always.
>>=20
>> When some bytes are peeked from queue and the peeking offset is non
>> negative it is moved forward so that the next peek will return next
>> portion of data.
>>=20
>> When non-peeking recvmsg occurs and the peeking offset is non negati=
ve
>> is is moved backward so that the next peek will still peek the prope=
r
>> data (i.e. the one that would have been picked if there were no non
>> peeking recv in between).
>>=20
>> The offset is set using per-proto opteration to let the protocol han=
dle
>> the locking issues and to check whether the peeking offset feature i=
s
>> supported by the protocol the socket belongs to.
>>=20
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
 ...
>=20
> small note : should be moved down by one line, after SCM_WIFI_STATUS
>=20
> Other than that,=20

You also didn't update all of the arch/*/include/asm/socket.h files.

I took care of all of this, but what should have been a simple matter
of me typing "git am --signoff foo.mbox" and "make" turned into a
10 minute exercise in raking leaves. :-/
