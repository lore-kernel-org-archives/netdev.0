From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] remove an outdated reference to T/TCP
Date: Wed, 7 Dec 2011 18:00:48 -0800
Message-ID: <CAK6E8=c289hbsF5kMEX9Li4XSCzq-2kfhLNha+u5DPw_zG3QJQ@mail.gmail.com>
References: <20111206200005.836D529006DD@tardy> <20111206.151920.696192671128392379.davem@davemloft.net>
 <4EDE8B8B.2000907@hp.com> <20111206.164243.402402261622724566.davem@davemloft.net>
 <CAK6E8=cne1UbOEcZ6ZfsJw-=qwUsO=yMEi3LNNsTpM_5crv0fg@mail.gmail.com> <1323248287.2690.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:56642 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756871Ab1LHCBJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 21:01:09 -0500
Received: by ggnr5 with SMTP id r5so1367098ggn.19
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2011 18:01:09 -0800 (PST)
In-Reply-To: <1323248287.2690.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2011 at 12:58 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 06 d=E9cembre 2011 =E0 15:00 -0800, Yuchung Cheng a =E9crit =
:
>
>> I am fine keeping the comment as is. =A0This does remind me to put m=
ore
>> comments on this part of the code in our upcoming Fast Open patch :)
>
> This sounds great.
>
> Is TFO patch using inetpeer cache to store cookies ?
>
> (I ask this because TFO paper I read mentions linux-2.6.34, I presume
> you couldnt use inetpeer at that time since it was IPv4 only)

Very interesting! I didn't know inetpeer cache earlier so we implement
own. duh! I will certainly look into it. Thanks for this tip.
=46rom the surface, it does not seem too difficult to extend inetpeer f=
or IPv6?

Yuchung
