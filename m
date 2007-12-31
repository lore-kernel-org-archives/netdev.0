From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/3] [UDP]: memory accounting in IPv4
Date: Mon, 31 Dec 2007 13:43:02 -0500
Message-ID: <47793836.10407@redhat.com>
References: <47775D8C.5010104@redhat.com> <47775E9A.40105@redhat.com> <477764B4.2030200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935AbXLaSoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 13:44:19 -0500
In-Reply-To: <477764B4.2030200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Hideo AOKI a =E9crit :
>> This patch adds UDP memory usage accounting in IPv4. Currently,
>> receiving buffer accounting is only supported.
>>
>> This patch is also introduced memory_allocated variable for UDP prot=
ocol.
>=20
> OK, but sockstat_seq_show() should be updated so that this
> udp_memory_allocated value can be read from /proc/net/sockstat ?

Yes, and I updated it in the first patch of the patch set.

I thought dividing patch made easy to review. But I was wrong.
Sorry about that.

Regards,
Hideo

--=20
Hitachi Computer Products (America) Inc.
