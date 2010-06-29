From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] fragment: add fast path
Date: Tue, 29 Jun 2010 23:29:03 +0900
Message-ID: <4C2A032F.3070700@linux-ipv6.org>
References: <1277434472-2845-1-git-send-email-xiaosuo@gmail.com> 	<1277819660.3531.568.camel@edumazet-laptop> <AANLkTimZ9Q-i9eTOfE3dae9Fru0dV2p2cEQqO3l8XBe9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Mitchell Erblich <erblichs@earthlink.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:49940 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754393Ab0F2O3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 10:29:14 -0400
In-Reply-To: <AANLkTimZ9Q-i9eTOfE3dae9Fru0dV2p2cEQqO3l8XBe9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Tue, Jun 29, 2010 at 9:54 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le vendredi 25 juin 2010 =E0 10:54 +0800, Changli Gao a =E9crit :
>>> add fast path
>>>
>>> As the fragments are sent in order in most of OSes, such as Windows=
, Darwin and
>>> FreeBSD, it is likely the new fragments are at the end of the inet_=
frag_queue.
>>> In the fast path, we check if the skb at the end of the inet_frag_q=
ueue is the
>>> prev we expect.
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> This patch is fine, but they are two indentation glitches.
>>
>=20
> Oh, Thanks. I'll fix them.

And, I think it is better not to just say it as "fast path"
because it does not sufficient.  Probably "fast path for
in-order fragments" or something like that.

Regards,

--yoshfuji
