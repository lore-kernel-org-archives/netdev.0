From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/3] [UDP]: memory accounting in IPv4
Date: Mon, 31 Dec 2007 19:58:46 +0100
Message-ID: <47793BE6.1070203@cosmosbay.com>
References: <47775D8C.5010104@redhat.com> <47775E9A.40105@redhat.com> <477764B4.2030200@cosmosbay.com> <47793836.10407@redhat.com>
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
Received: from gw1.cosmosbay.com ([86.65.150.130]:43977 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbXLaTAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 14:00:14 -0500
In-Reply-To: <47793836.10407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hideo AOKI a =E9crit :
> Eric Dumazet wrote:
>> Hideo AOKI a =E9crit :
>>> This patch adds UDP memory usage accounting in IPv4. Currently,
>>> receiving buffer accounting is only supported.
>>>
>>> This patch is also introduced memory_allocated variable for UDP pro=
tocol.
>> OK, but sockstat_seq_show() should be updated so that this
>> udp_memory_allocated value can be read from /proc/net/sockstat ?
>=20
> Yes, and I updated it in the first patch of the patch set.
>=20
> I thought dividing patch made easy to review. But I was wrong.
> Sorry about that.

No problem Hideo, I think you did a good job with this UDP memory accou=
nting=20
and were very patient.

Thank you



