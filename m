From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net-next v2] ipv6: Do not iterate over all interfaces when
 finding source address on specific interface.
Date: Sat, 11 Jul 2015 18:21:10 +0900
Message-ID: <CAAedzxpMP-DmKOy-BfQkReGWmbujGqM_JsdmYtcuxVDqAdXNKg@mail.gmail.com>
References: <559F7B27.6030205@miraclelinux.com> <20150710.231943.1262522002810525503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36052 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397AbbGKJVg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 05:21:36 -0400
Received: by widjy10 with SMTP id jy10so32526147wid.1
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2015 02:21:35 -0700 (PDT)
In-Reply-To: <20150710.231943.1262522002810525503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm, when I run a UML linux with this patch (which, I'm ashamed to
say, I failed to do before) I get these kinds of errors:

    unregister_netdevice: waiting for <TAPdevice> to become free.
Usage count =3D 1
    unregister_netdevice: waiting for <TAPdevice> to become free.
Usage count =3D 1

Perhaps they're unrelated... I'm still investigating.

On 11 July 2015 at 15:19, David Miller <davem@davemloft.net> wrote:
> From: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki=
=2Eyoshifuji@miraclelinux.com>
> Date: Fri, 10 Jul 2015 16:58:31 +0900
>
>> If outgoing interface is specified and the candidate address is
>> restricted to the outgoing interface, it is enough to iterate
>> over that given interface only.
>>
>> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com=
>
>> Acked-by: Erik Kline <ek@google.com>
>
> Applied, thanks!
