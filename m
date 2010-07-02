From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/9] netfilter: nf_nat: support user-specified SNAT rules
 in LOCAL_IN
Date: Fri, 2 Jul 2010 14:58:38 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007021452430.11763@obet.zrqbmnf.qr>
References: <1278064342-19059-1-git-send-email-kaber@trash.net> <1278064342-19059-2-git-send-email-kaber@trash.net> <alpine.LSU.2.01.1007021212490.16691@obet.zrqbmnf.qr> <4C2DBCD3.20208@trash.net> <alpine.LSU.2.01.1007021416120.30410@obet.zrqbmnf.qr>
 <4C2DDD29.7030503@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:39140 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756802Ab0GBM6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jul 2010 08:58:40 -0400
In-Reply-To: <4C2DDD29.7030503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2010-07-02 14:35, Patrick McHardy wrote:
>>> Sure they do, if they are destined for the host itself. I'm not sur=
e
>>> what's so hard to understand about this patch, you have f.i. multip=
le
>>> tunnels using the same remote network, on INPUT and POSTROUTING you=
 SNAT
>>> them to seperate networks based on criteria like the network device=
 or
>>> the IPsec tunnel to be able to distinguish them.
>>>   =20
>>
>> But they are already distinguishable by the ctmark that is applied
>> to these connections to do routing of the reply, are they not?
>> =20
>
> Its not (only) about routing, you simply can't have two connections u=
sing
> the same identity.

Which is why the zone thing is added.

Ah, but I now see that you need to select a zone for it first.. touch=C3=
=A9.

Still this SNAT-on-INPUT leaves a second taste. Adding another address=20
to the tunnel master and using DNAT-on-PREROUTING for local deliveries=20
would have also made the connections unambiguous.
