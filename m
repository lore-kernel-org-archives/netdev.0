From: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
Subject: Re: [PATCH] net:ppp: replace too strict capability restriction on opening /dev/ppp
Date: Sun, 19 Jun 2016 07:31:11 +0200
Message-ID: <9AA09B84-509B-4A05-95AE-8607F292318D@tuna.tsinghua.edu.cn>
References: <15AED149-BC4D-4B8F-B173-3F652A46FA35@tuna.tsinghua.edu.cn> <20160618.222418.1416412894394180688.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	richard.weinberger@gmail.com, g.nault@alphalink.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35719 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbcFSFbO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 01:31:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id a66so1459977wme.2
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 22:31:13 -0700 (PDT)
In-Reply-To: <20160618.222418.1416412894394180688.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> =D4=DA 2016=C4=EA6=D4=C219=C8=D5=A3=AC07:24=A3=ACDavid Miller <davem@=
davemloft.net> =D0=B4=B5=C0=A3=BA
>=20
> From: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
> Date: Sun, 19 Jun 2016 07:21:27 +0200
>=20
>> This patch removes the check for CAP_NET_ADMIN in the initial namesp=
ace
>> when opening /dev/open. Instead, CAP_NET_ADMIN is checked in the use=
r
>> namespace the net namespace was created so that /dev/ppp cat get ope=
ned
>> in a unprivileged container.
>>=20
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Cc: Richard Weinberger <richard.weinberger@gmail.com>
>> Cc: Guillaume Nault <g.nault@alphalink.fr>
>> Cc: Miao Wang <shankerwangmiao@gmail.com>
>> Signed-off-by: Miao Wang <miao.wang@tuna.tsinghua.edu.cn>
>=20
> Why are you posting this again?

Sorry for re-sending this e-mail. But the e-mail address of mine has be=
en=20
changed. And I haven=A1=AFt seen this e-mail in several kernel mail lis=
t=20
archives after a night of sleep. I=A1=AFm wondering if the e-mail is se=
nt
correctly. So I finally decide to re-send this e-mail. Again, I feel
sorry for sending the same thing for two times.

BTW, how can i judge if my e-mail is correctly sent to the mail list?
