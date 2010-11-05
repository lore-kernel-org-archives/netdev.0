From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more
 per-cpu memory?
Date: Fri, 05 Nov 2010 21:53:54 +0100
Message-ID: <1288990434.2665.376.camel@edumazet-laptop>
References: <4CD43C87.5040403@candelatech.com>
	 <1288980361.2882.1070.camel@edumazet-laptop>
	 <4CD449A5.5070305@candelatech.com>
	 <1288988403.2665.268.camel@edumazet-laptop>
	 <4CD46892.6050408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55335 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab0KEUyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 16:54:00 -0400
In-Reply-To: <4CD46892.6050408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 13:26 -0700, Ben Greear a =C3=A9cri=
t :

>=20
> I was also wondering if it would make sense to allow one to disable
> the snmp stats for ipv6?  I don't think I have any use for those
> stats anyway..
>=20

I agree. IPV6 have per device SNMP fields, percpu... thats probably not
needed.

We have many SNMP fields that could avoid being percpu, even for ipv4.



