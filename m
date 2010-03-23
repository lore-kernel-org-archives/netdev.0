From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
 online CPUs default
Date: Tue, 23 Mar 2010 12:38:26 +0100
Message-ID: <1269344306.2983.16.camel@edumazet-laptop>
References: <4BA85EA2.1090304@gmail.com>
	 <1269329250.3043.19.camel@edumazet-laptop>
	 <412e6f7f1003230303l69fc142ey1581fff4c3e749be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:51469 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499Ab0CWLic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 07:38:32 -0400
Received: by gxk9 with SMTP id 9so835920gxk.8
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 04:38:31 -0700 (PDT)
In-Reply-To: <412e6f7f1003230303l69fc142ey1581fff4c3e749be@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 18:03 +0800, Changli Gao a =C3=A9crit :

>=20
> Ben Hutchings raised this question, but nobody replied with any messa=
ge.
>=20
> I do think distributing packets fairly among all the online CPUs will
> helps most of users. I remember the smp_affinity of IRQ is the
> online_cpu_mask be default.
>=20

I know _many_ applications that perform better when all network IRQS ar=
e
directed to one CPU only. Single threaded UDP server for example, with
fast answer, or routers, or ...

Many sysadmins tuned their machine to meet this requirement. Installing
2.6.35, if RPS enabled by default will make them unhappy, especially if
CONFIG_SYSFS is not set, since they wont be able to change RPS settings=
=2E

If RPS was good for all workloads, activating it would make sense, but
this is not the case.


