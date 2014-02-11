From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH] net: rtnetlink: fix correct size given to memset
Date: Tue, 11 Feb 2014 08:01:25 -0800 (PST)
Message-ID: <1392134485.29083.YahooMailNeo@web125506.mail.ne1.yahoo.com>
References: <1392127598-3719-1-git-send-email-fx.lebail@yahoo.com> <1392132522.6615.85.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NETDEV <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm24-vm5.bullet.mail.ne1.yahoo.com ([98.138.91.246]:45497 "EHLO
	nm24-vm5.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbaBKQHd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 11:07:33 -0500
In-Reply-To: <1392132522.6615.85.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Eric Dumazet <eric.dumazet@gmail.com>

> To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
>>  Find by cppcheck:
>>  [net/core/rtnetlink.c:1842]: (warning) Using size of pointer linkin=
fo=20
> instead of size of its data.
>>=20
>>  Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
>>  ---
>>=20
>>  The diagnosis of cppcheck seems relevant.
>>=20
>> =A0 net/core/rtnetlink.c |=A0 =A0 2 +-
>> =A0 1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
> This is absolutely wrong.
>=20
> =A0=A0=A0 struct nlattr *linkinfo[IFLA_INFO_MAX+1];
>=20
> sizeof(linkinfo) is totally appropriate=20
>=20
> sizeof(*linkinfo) is equal to sizeof(void *), and this is not what we
> need here.

Oops, sorry for the noise.
