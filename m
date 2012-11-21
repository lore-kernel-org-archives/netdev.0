From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/netfilter: strcpy for timeout->name
Date: Wed, 21 Nov 2012 20:17:51 +0800
Message-ID: <50ACC66F.3080506@asianux.com>
References: <50AB0249.20802@asianux.com> <50AB12EE.6050802@gmail.com> <50AB4386.3080603@asianux.com> <20121121113901.GA25102@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xue Ying <ying.xue0@gmail.com>, David Miller <davem@davemloft.net>,
	Shan Wei <shanwei88@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:31695 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2KUMQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:16:58 -0500
In-Reply-To: <20121121113901.GA25102@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B411=E6=9C=8821=E6=97=A5 19:39, Florian Westphal =E5=
=86=99=E9=81=93:
> Chen Gang <gang.chen@asianux.com> wrote:
>> Please help checking net/netfilter/nfnetlink_cttimeout.c:
>>   I suggest, we use strncpy instead of strcpy at line 143.=20
>>   just like we have already used strncmp at line 94.
> [..]
>>   after checking the calling work flow:
>>     the length of nla_data(cda[CTA_TIMEOUT_NAME]) is not limited in =
server side.
>=20
> Good catch, classic buffer overflow.
>=20
> I've sent a patch to add the missing "len" policy.  Thanks for report=
ing
> this bug.

  thank you for your reply, too.

  regard

gchen

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


--=20
Chen Gang

Asianux Corporation
