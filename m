From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix incorrect LOCKDROPPEDICMPS counter
Date: Sun, 20 Jan 2013 17:22:37 -0500 (EST)
Message-ID: <20130120.172237.308780232580011846.davem@davemloft.net>
References: <1358647837.3464.1050.camel@edumazet-glaptop>
	<CADVnQynpupJ3HTmSP3dxEE6MGi0bpq=B_WQMqdxnmxNSQLq3OA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, maze@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515Ab3ATWWm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 17:22:42 -0500
In-Reply-To: <CADVnQynpupJ3HTmSP3dxEE6MGi0bpq=B_WQMqdxnmxNSQLq3OA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Neal Cardwell <ncardwell@google.com>
Date: Sat, 19 Jan 2013 23:19:14 -0500

> On Sat, Jan 19, 2013 at 9:10 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> commit 563d34d057 (tcp: dont drop MTU reduction indications)
>> added an error leading to incorrect accounting of
>> LINUX_MIB_LOCKDROPPEDICMPS
>>
>> If socket is owned by the user, we want to increment
>> this SNMP counter, unless the message is a
>> (ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED) one.
>>
>> Reported-by: Maciej =AFenczykowski <maze@google.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Neal Cardwell <ncardwell@google.com>
>=20
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks everyone.
