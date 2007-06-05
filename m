From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] TCP : use LIMIT_NETDEBUG in tcp_retransmit_timer()
Date: Tue, 05 Jun 2007 09:07:26 +0200
Message-ID: <46650BAE.9070301@cosmosbay.com>
References: <4663BBA4.70009@cosmosbay.com> <20070605.000027.59657229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54639 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765AbXFEHHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 03:07:35 -0400
In-Reply-To: <20070605.000027.59657229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 04 Jun 2007 09:13:40 +0200
>=20
>> LIMIT_NETDEBUG allows the admin to disable some warning messages (ec=
ho 0=20
>>  >/proc/sys/net/core/warnings).
>>
>> The "TCP: Treason uncloaked!" message can use this facility.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> That's pretty difficult to trigger remotely, and the last time
> we saw a legitimate case of this it was actually a bug in the
> Linux TCP stack which we've long since fixed.
>=20
> I would rather not let people easily disable this, since it
> finds bugs and I can't see someone seriously exploiting this
> to spam your logs.
>=20
> I suppose you disagree :)

Well, I dont know..

Should I try to contact 222.39.111.164 and kindly ask him not to trigge=
r this=20
annoying message ?

Is this remote peer running an old linux, or is it a bug in the current=
=20
linux-2.6.22-rc4 kernel that my server runs ?

TCP: Treason uncloaked! Peer 222.39.111.164:3336/443 shrinks window=20
768445619:768445688. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:1557/443 shrinks window=20
979986676:979986745. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2819/443 shrinks window=20
903113077:903113146. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2303/443 shrinks window=20
919019510:919019579. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2689/443 shrinks window=20
986306349:986306418. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2811/443 shrinks window=20
1125084057:1125084126. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2394/443 shrinks window=20
1141647532:1141647601. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2928/443 shrinks window=20
1278301359:1278301428. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3034/443 shrinks window=20
1408574195:1408574264. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2942/443 shrinks window=20
1453238832:1453238901. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3384/443 shrinks window=20
1883648213:1883648282. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3069/443 shrinks window=20
1913770905:1913770974. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2852/443 shrinks window=20
1956256538:1956256607. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3485/443 shrinks window=20
2034019830:2034019899. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3104/443 shrinks window=20
2054229702:2054229771. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2897/443 shrinks window=20
2070392361:2070392430. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3485/443 shrinks window=20
2034019830:2034019899. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3626/443 shrinks window=20
2167403488:2167403557. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3104/443 shrinks window=20
2054229702:2054229771. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2897/443 shrinks window=20
2070392361:2070392430. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3626/443 shrinks window=20
2167403488:2167403557. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2991/443 shrinks window=20
2283637853:2283637922. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3128/443 shrinks window=20
2283549171:2283549240. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2991/443 shrinks window=20
2283637853:2283637922. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3128/443 shrinks window=20
2283549171:2283549240. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:2991/443 shrinks window=20
2283637853:2283637922. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3128/443 shrinks window=20
2283549171:2283549240. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:4075/443 shrinks window=20
2788112983:2788113052. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:4075/443 shrinks window=20
2788112983:2788113052. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3786/443 shrinks window=20
2905215394:2905215463. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:4075/443 shrinks window=20
2788112983:2788113052. Repaired.
TCP: Treason uncloaked! Peer 222.39.111.164:3786/443 shrinks window=20
2905215394:2905215463. Repaired.


