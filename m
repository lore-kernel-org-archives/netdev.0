From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Fri, 18 Nov 2011 17:34:06 +0100
Message-ID: <1321634046.3277.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EC2CA52.6020104@icdsoft.com>
	 <1321391355.2602.0.camel@edumazet-laptop> <4EC439F2.3080809@icdsoft.com>
	 <20111116223330.08de9e52@asterix.rh> <4EC4C160.6010804@icdsoft.com>
	 <20111117111145.252924f5@asterix.rh>
	 <1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117133724.59684d28@asterix.rh>
	 <1321547510.2751.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117144038.61b0525b@asterix.rh>
	 <1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117150145.25e01a75@asterix.rh>
	 <1321550302.2751.81.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321551536.2751.87.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321632128.3277.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111118143016.01e24b37@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33153 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905Ab1KRQeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 11:34:11 -0500
Received: by bke11 with SMTP id 11so3634204bke.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 08:34:10 -0800 (PST)
In-Reply-To: <20111118143016.01e24b37@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 novembre 2011 =C3=A0 14:30 -0200, Flavio Leitner a =C3=A9=
crit :

> I know we are reverting to get it fixed, but this adds the routing
> cache back, so what is the plan? Revert to get it working and then
> think on new approach to remove the route cache again later?
>=20
> I had one previous patch using the routing cache posted to the list,
> but it won't fix the route flush problem.
>=20

I dont "add the routing cache back".

Note I only fix existing route entries in the cache ;)

A "revert" is probably safe, since we should push a fix for 3.0/3.1/3.2
kernels...
