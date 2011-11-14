From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: reduce percpu needs for icmpv6msg mibs
Date: Mon, 14 Nov 2011 17:26:13 +0100
Message-ID: <1321287973.2272.58.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321183444.17837.21.camel@edumazet-laptop>
	 <20111114081253.226e2b66@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52142 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202Ab1KNQ0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 11:26:17 -0500
Received: by fagn18 with SMTP id n18so3174640fag.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 08:26:16 -0800 (PST)
In-Reply-To: <20111114081253.226e2b66@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 novembre 2011 =C3=A0 08:12 -0800, Stephen Hemminger a =C3=A9=
crit :

> Probably should do this for ICMP for IPv4 and all the other
> non hot counters. The whole per-cpu SNMP MIB stuff for all counters
> is massive overkill.

Well, this (ICMP for IPv4) was already done some days ago, I did the
IPv6 part after IPv4, once David agreed it was a useful patch.


Thanks !
