From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] net: pack skb_shared_info more efficiently
Date: Thu, 05 Jan 2012 14:09:50 -0500 (EST)
Message-ID: <20120105.140950.1725945490303900670.davem@davemloft.net>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	<1325783624-14601-1-git-send-email-ian.campbell@citrix.com>
	<1325788258.4759.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758091Ab2AETJz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:09:55 -0500
In-Reply-To: <1325788258.4759.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jan 2012 19:30:58 +0100

> Le jeudi 05 janvier 2012 =E0 17:13 +0000, Ian Campbell a =E9crit :
>> nr_frags can be 8 bits since 256 is plenty of fragments. This allows=
 it to be
>> packed with tx_flags.
>>=20
>> Also by moving ip6_frag_id and dataref (both 4 bytes) next to each o=
ther we can
>> avoid a hole between ip6_frag_id and frag_list on 64 bit systems.
>>=20
>> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
