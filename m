From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 17:56:58 +0100
Message-ID: <1289494618.17691.1498.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>
	 <1289427705.17691.52.camel@edumazet-laptop>
	 <4CDB226A.8080903@candelatech.com>
	 <1289432184.17691.141.camel@edumazet-laptop>
	 <4CDB2EBC.2090905@candelatech.com>
	 <1289459012.17691.1001.camel@edumazet-laptop>
	 <4CDC1C9A.3070102@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51394 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469Ab0KKQ5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 11:57:06 -0500
Received: by yxn35 with SMTP id 35so90247yxn.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 08:57:04 -0800 (PST)
In-Reply-To: <4CDC1C9A.3070102@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 novembre 2010 =C3=A0 08:40 -0800, Ben Greear a =C3=A9crit :

> So, they assume counters are exactly 32 or 64 bits.
> Your example of the 36-bit counter would break their
> assumptions of 32 or 64 bits.
>=20

They 'assume'. I am not. How do you handle counters that suddenly go to
0 ?

> I agree that you can guess if the counter is 32 or 64, at least with =
today's
> hardware and relatively normal poll times, and the requirement that t=
he
> counters can ONLY be 32 or 64 bits.  I still consider it a kludge to
> return 32 bit counters in stats64, however.  Would you consider
> a patch to have netlink pay attention to whether the stats are 32 or
> 64 (based on a flag returned from dev_get_stats perhaps)?

So what ? How is it going to help /proc/net/dev users (most apps use it=
)

Could you please adapt your software, and not adapt linux to your
needs ? Dont your software runs on linux 2.6.32 ?



