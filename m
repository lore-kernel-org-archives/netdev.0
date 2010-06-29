From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] fragment: add fast path
Date: Tue, 29 Jun 2010 22:15:50 +0800
Message-ID: <AANLkTimZ9Q-i9eTOfE3dae9Fru0dV2p2cEQqO3l8XBe9@mail.gmail.com>
References: <1277434472-2845-1-git-send-email-xiaosuo@gmail.com>
	<1277819660.3531.568.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Mitchell Erblich <erblichs@earthlink.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48081 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754919Ab0F2OQL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 10:16:11 -0400
Received: by vws5 with SMTP id 5so1492786vws.19
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 07:16:10 -0700 (PDT)
In-Reply-To: <1277819660.3531.568.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 29, 2010 at 9:54 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 25 juin 2010 =E0 10:54 +0800, Changli Gao a =E9crit :
>> add fast path
>>
>> As the fragments are sent in order in most of OSes, such as Windows,=
 Darwin and
>> FreeBSD, it is likely the new fragments are at the end of the inet_f=
rag_queue.
>> In the fast path, we check if the skb at the end of the inet_frag_qu=
eue is the
>> prev we expect.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> This patch is fine, but they are two indentation glitches.
>

Oh, Thanks. I'll fix them.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
