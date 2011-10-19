From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: give proper headroom in pppol2tp_xmit()
Date: Wed, 19 Oct 2011 00:12:16 -0400 (EDT)
Message-ID: <20111019.001216.1105373017883639047.davem@davemloft.net>
References: <1318002357.3207.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111018.233444.955647916101091708.davem@davemloft.net>
	<1318996826.19139.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab1JSEMT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:12:19 -0400
In-Reply-To: <1318996826.19139.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Oct 2011 06:00:26 +0200

> Le mardi 18 octobre 2011 =E0 23:34 -0400, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> > Maybe we should add a counter to help diagnose too many
>> > pskb_expand_head() calls...
>>=20
>=20
>> I think it's the kind of event that deserves a tracepoint, this way =
one
>> could use perf to notice and diagnose such problems.
>=20
> Target of the patch is an embedded device, MIPS based.=20
>=20
> I am not sure perf is available on it.

No MIPS specific code is needed to support perf tracepoint
analysis features.

And even if core perf support were required, MIPS's lack of proper
perf support would not the basis upon which we would add features.
