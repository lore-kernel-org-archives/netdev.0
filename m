From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Fri, 18 Nov 2011 18:07:53 +0100
Message-ID: <1321636073.3277.38.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
	 <1321634046.3277.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111118150512.5f66f7d2@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40396 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666Ab1KRRH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 12:07:58 -0500
Received: by bke11 with SMTP id 11so3676111bke.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 09:07:57 -0800 (PST)
In-Reply-To: <20111118150512.5f66f7d2@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 novembre 2011 =C3=A0 15:05 -0200, Flavio Leitner a =C3=A9=
crit :

> Sorry, I meant that we are trying to avoid doing this:
> +			hash =3D rt_hash(daddr, skeys[s], ikeys[i],rt_genid(net));
> +
> +			rthp =3D &rt_hash_table[hash].chain;
> +
> +			while ((rt =3D rcu_dereference(*rthp)) !=3D NULL) {
> +				rthp =3D &rt->dst.rt_next;

Sure, but this is still needed right now.

Once route cache is removed, this loop wont exist anymore ;)
