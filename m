From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Mon, 30 Aug 2010 06:42:31 +0000
Message-ID: <20100830064231.GA7060@ff.dom.local>
References: <1283107162.2297.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53766 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0H3Gmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 02:42:39 -0400
Received: by fxm13 with SMTP id 13so3044018fxm.19
        for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 23:42:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1283107162.2297.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-08-29 20:39, Eric Dumazet wrote:
> Le dimanche 29 ao=C3=BBt 2010 =C3  10:06 -0700, David Miller a =C3=A9=
crit :
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Sun, 29 Aug 2010 11:59:51 +0200
>>
>>> Actually, when GRO compares napi->dev to skb->dev?
>>
>> Hmmm, I thought the code made a skb->dev comparison with the
>> existing SKBs in the list when checking for same-flow matches.
>>
>> It doesn't, probably based upon the assumption that a NAPI
>> instance maps to a unique device, the very topic we're
>> discussing right now :-/
>>
>>
>=20
> It does the check, Stephen added it in the commit I mentioned to star=
t
> this thread.
>=20
> With net-next-2.6 this now reads :
>=20

Since Stephen didn't seem to miss this too much it seems quite obvious
to me this check should be removed.

Jarek P.
