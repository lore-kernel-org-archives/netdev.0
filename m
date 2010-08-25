From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS patch questions
Date: Wed, 25 Aug 2010 15:16:50 +0200
Message-ID: <1282742210.2487.277.camel@edumazet-laptop>
References: <AANLkTikXLwDA5cTevWiBRf+6BvZFEs+YSVqZk7wJLEjq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lal <learner.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:40751 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab0HYNQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 09:16:56 -0400
Received: by ewy23 with SMTP id 23so216433ewy.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 06:16:54 -0700 (PDT)
In-Reply-To: <AANLkTikXLwDA5cTevWiBRf+6BvZFEs+YSVqZk7wJLEjq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 18:05 +0530, Lal a =C3=A9crit :
> I am evaluating RPS patch from Tom Herbert. I have some questions
> regarding this patch.
>=20
> 1. Can __smp_call_function_single be called from bottom half handler?
> I presume, yes.
>=20

right.

> 2. I am working on 2.6.21 kernel which have neither
> __smp_call_function_single nor smp_call_function_single. I used
> smp_call_function_single from some other kernel version but this too
> can not be called from bottom half handler (just like
> smp_call_function). Did somebody try to write such function for 2.6.2=
1
> (or older kernel) which can be called from bottom halves?

2.6.21 is too old for us ;)

>=20
> 3. One option I've is to upgrade to 2.6.27 kernel which has
> __smp_call_function_single. I see a comment that this function must
> not be called with interrupt disabled. Does it mean it can be called
> from bottom half handler?
>=20

__smp_call_function_single must be called with hard irqs enabled.

bottom half handlers (softirqs) do run with hard irqs enabled.



