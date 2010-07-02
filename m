From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/9] netfilter: nf_nat: support user-specified SNAT rules
 in LOCAL_IN
Date: Fri, 02 Jul 2010 16:07:16 +0200
Message-ID: <4C2DF294.5010206@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net> <1278064342-19059-2-git-send-email-kaber@trash.net> <alpine.LSU.2.01.1007021212490.16691@obet.zrqbmnf.qr> <4C2DBCD3.20208@trash.net> <alpine.LSU.2.01.1007021416120.30410@obet.zrqbmnf.qr> <4C2DDD29.7030503@trash.net> <alpine.LSU.2.01.1007021452430.11763@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50433 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757172Ab0GBOHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 10:07:17 -0400
In-Reply-To: <alpine.LSU.2.01.1007021452430.11763@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Friday 2010-07-02 14:35, Patrick McHardy wrote:
>  =20
>>>> Sure they do, if they are destined for the host itself. I'm not su=
re
>>>> what's so hard to understand about this patch, you have f.i. multi=
ple
>>>> tunnels using the same remote network, on INPUT and POSTROUTING yo=
u SNAT
>>>> them to seperate networks based on criteria like the network devic=
e or
>>>> the IPsec tunnel to be able to distinguish them.
>>>>   =20
>>>>        =20
>>> But they are already distinguishable by the ctmark that is applied
>>> to these connections to do routing of the reply, are they not?
>>> =20
>>>      =20
>> Its not (only) about routing, you simply can't have two connections =
using
>> the same identity.
>>    =20
>
> Which is why the zone thing is added.
>  =20

I'm not talking about conntrack at all. A connection needs
a unique identity. Just look at the socket lookup code.

> Ah, but I now see that you need to select a zone for it first.. touch=
=C3=A9.
>
> Still this SNAT-on-INPUT leaves a second taste. Adding another addres=
s=20
> to the tunnel master and using DNAT-on-PREROUTING for local deliverie=
s=20
> would have also made the connections unambiguous

