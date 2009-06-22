From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] IPv6: Add 'autoconf' and 'disable_ipv6' module parameters
Date: Mon, 22 Jun 2009 11:25:15 -0400
Message-ID: <4A3FA25B.5040909@hp.com>
References: <4A204A31.4010105@hp.com> <20090601.030835.261332360.davem@davemloft.net> <4A23E014.4040909@hp.com> <alpine.LNX.2.01.0906210557500.11635@firda.kolla.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux@kolla.no, vladislav.yasevich@hp.com
To: =?UTF-8?B?S29sYmrDuHJuIEJhcm1lbg==?= <kolbjorn.barmen@uninett.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:37120 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbZFVPZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 11:25:16 -0400
In-Reply-To: <alpine.LNX.2.01.0906210557500.11635@firda.kolla.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kolbj=C3=B8rn Barmen wrote:
> Anyways... when I apply the patch and try too compile, I get:
>=20
> net/ipv6/addrconf.c: In function 'addrconf_disable_ipv6':
> net/ipv6/addrconf.c:4029: error: implicit declaration of function 're=
start_syscall'
> make[2]: *** [net/ipv6/addrconf.o] Error 1
> make[1]: *** [net/ipv6] Error 2

Can you send me your .config?  restart_syscall() is called further-up i=
n
addrconf_fixup_forwarding() which didn't seem to generate an error.  Or=
 can
you try Davem's latest net-next-2.6 tree?

Thanks,

-Brian
