From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/3] [UDP]: memory accounting in IPv4
Date: Sun, 30 Dec 2007 10:28:20 +0100
Message-ID: <477764B4.2030200@cosmosbay.com>
References: <47775D8C.5010104@redhat.com> <47775E9A.40105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:49995 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbXL3JcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 04:32:22 -0500
In-Reply-To: <47775E9A.40105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hideo AOKI a =E9crit :
> This patch adds UDP memory usage accounting in IPv4. Currently,
> receiving buffer accounting is only supported.
>=20
> This patch is also introduced memory_allocated variable for UDP proto=
col.

OK, but sockstat_seq_show() should be updated so that this=20
udp_memory_allocated value can be read from /proc/net/sockstat ?

Thank you

