From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: flow_dissector.c missing include
 linux/export.h
Date: Tue, 24 Jan 2012 15:51:35 -0500 (EST)
Message-ID: <20120124.155135.1784877918701583546.davem@davemloft.net>
References: <1327420643.4549.113.camel@probook>
	<1327421731.7231.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAP=VYLr-28ZSG7tURdGbp5nG4JdOMh_GZfv0HnCxpjv+GggMLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, jdb@comx.dk, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756572Ab2AXUxo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 15:53:44 -0500
In-Reply-To: <CAP=VYLr-28ZSG7tURdGbp5nG4JdOMh_GZfv0HnCxpjv+GggMLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 24 Jan 2012 14:44:21 -0500

> On Tue, Jan 24, 2012 at 11:15 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> Le mardi 24 janvier 2012 =E0 16:57 +0100, Jesper Dangaard Brouer a =E9=
crit :
>>> The file net/core/flow_dissector.c seems to be missing
>>> including linux/export.h.
>>>
>>> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
>>> ---
>>> =A0net/core/flow_dissector.c | =A0 =A01 +
>>> =A01 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>>> index 0985b9b..a225089 100644
>>> --- a/net/core/flow_dissector.c
>>> +++ b/net/core/flow_dissector.c
>>> @@ -1,4 +1,5 @@
>>> =A0#include <linux/skbuff.h>
>>> +#include <linux/export.h>
>>> =A0#include <linux/ip.h>
>>> =A0#include <linux/ipv6.h>
>>> =A0#include <linux/if_vlan.h>
>>
>>
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>>
>> Hmm, not sure how you found this, since export.h is included from
>> linux/netdevice.h (via net/netprio_cgroup.h & linux/module.h)
>>
>> Or maybe you want to remove linux/module.h inclusion from
>> net/netprio_cgroup.h ???
>=20
> That would be the better solution.  I had them all killed off and it
> would be nice to try and keep it that way as long as possible.
>=20
> I'll look into this if that wasn't part of Jesper's original intentio=
n.

Jesper did you actually hit this problem and get a real build
failure?
