From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 2/8] tcp: use limited socket backlog
Date: Mon, 08 Mar 2010 10:46:52 -0800 (PST)
Message-ID: <20100308.104652.23696042.davem@davemloft.net>
References: <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
	<1267769972.2867.1.camel@edumazet-laptop>
	<1268040117.6148.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yi.zhu@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754115Ab0CHSqc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 13:46:32 -0500
In-Reply-To: <1268040117.6148.68.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Mar 2010 10:21:57 +0100

> Le vendredi 05 mars 2010 =E0 07:19 +0100, Eric Dumazet a =E9crit :
>=20
>> I'll submit a followup patch to add a MIB counter if your patch gets=
 in.
>>=20
>=20
> As promised, here it is.
>=20
> [PATCH] tcp: Add SNMP counters for backlog and min_ttl drops
>=20
> Commit 6b03a53a (tcp: use limited socket backlog) added the possibili=
ty
> of dropping frames when backlog queue is full.
>=20
> Commit d218d111 (tcp: Generalized TTL Security Mechanism) added the
> possibility of dropping frames when TTL is under a given limit.
>=20
> This patch adds new SNMP MIB entries, named TCPBacklogDrop and=20
> TCPMinTTLDrop, published in /proc/net/netstat in TcpExt: line
>=20
> netstat -s | egrep "TCPBacklogDrop|TCPMinTTLDrop"
>     TCPBacklogDrop: 0
>     TCPMinTTLDrop: 0
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
