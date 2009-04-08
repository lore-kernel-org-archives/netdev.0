From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Wed, 08 Apr 2009 10:12:33 +0200
Message-ID: <49DC5C71.2040505@cosmosbay.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net> <49BED109.3020504@cosmosbay.com> <49D66379.7070106@athenacr.com> <49D8B6DA.7050902@cosmosbay.com> <49DBB2BA.1010100@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43157 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761851AbZDHIN5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 04:13:57 -0400
In-Reply-To: <49DBB2BA.1010100@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Bloniarz a =E9crit :
> Eric Dumazet wrote:
>> Brian Bloniarz a =E9crit :
>>> We've been experimenting with this softirq-delay patch in productio=
n,
> and
>>> have seen some hard-to-reproduce crashes. We finally managed to
> capture a
>>> kexec crashdump this morning.
>>
>> Pointer being null might tell us that we managed to call
> inet_def_readable()
>> without socket lock hold...
>=20
> False alarm -- I think I did the backport to 2.6.24 incorrectly. 2.6.=
24 was
> before the UDP receive path started taking the socket lock, so
> inet_def_readable's assumption doesn't hold.
>=20
> Sorry to waste everyone's time.
>=20

Thanks for doing this discovery work and analysis.=20

I am currently off-computers and could not do this until next week.

So, if you want to use 2.6.24, we need to back port other patches as we=
ll ?

