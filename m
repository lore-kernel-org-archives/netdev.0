From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] ipv6: fix array index in ip6_mc_add_src()
Date: Mon, 2 Apr 2012 18:16:14 +0800
Message-ID: <CAJFZqHwAFao9En4LRBST3YSufbrjbtsV09_h9fOVTSsCHtsT_w@mail.gmail.com>
References: <1333269926-24681-1-git-send-email-roy.qing.li@gmail.com>
	<20120401.151318.984514868716173152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:58224 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658Ab2DBKQP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 06:16:15 -0400
Received: by obbtb18 with SMTP id tb18so1878738obb.19
        for <netdev@vger.kernel.org>; Mon, 02 Apr 2012 03:16:14 -0700 (PDT)
In-Reply-To: <20120401.151318.984514868716173152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/4/2 David Miller <davem@davemloft.net>:
> From: roy.qing.li@gmail.com
> Date: Sun, =A01 Apr 2012 16:45:26 +0800
>
>> From: RongQing.Li <roy.qing.li@gmail.com>
>>
>> Convert array index from the loop bound to the loop index.
>>
>> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
>
> That's not all you are doing:
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (void) ip6_mc_del1_src(pmc=
, sfmode, &psfsrc[i]);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ip6_mc_del1_src(pmc, sfmod=
e, &psfsrc[j]);
>
> You absolutely MUST mention and explain this (void) removal.
> It's probably there to elide an unchecked return value
> warning from the compiler.

since ip6_mc_del1_src() does not use __must_check likely attribute.
I try to compile with several gcc warning options, but do not
find which options can report the unchecked return value.

Maybe other tools will complain the unchecked return value.

So I will keep the void.

-R
