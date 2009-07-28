From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: net_assign_generic()  fix
Date: Tue, 28 Jul 2009 15:16:37 +0200
Message-ID: <4A6EFA35.3060309@gmail.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com> <4A6EF0BF.2050801@gmail.com> <4A6EF705.6070403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41636 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754107AbZG1NQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 09:16:56 -0400
In-Reply-To: <4A6EF705.6070403@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =C3=A9crit :
>> Hmm...
>>
>> Real bug may be fixed by followed patch ? (yet untested, sorry...)
>>
>> [PATCH] net: net_assign_generic() fix=20
>>
>> memcpy() should take into account size of pointers,
>> not only number of pointers to copy.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Acked-by: Pavel Emelyanov <xemul@openvz.org>

Thanks.

Still this doesnt explain the crash, because initial number of pointers=
 is 13
(INITIAL_NET_GEN_PTRS)

We probably never realloc this array, unless a module forgets to
unregister_pernet_gen_device() and we load/unload it many times ?

