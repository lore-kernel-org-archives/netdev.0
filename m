From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 00:22:39 +0800
Message-ID: <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com>
References: <4D0DEDF9.7020102@itcare.pl> <1292773433.18869.153.camel@edumazet-laptop>
 <4D0E2E52.3090802@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:48694 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951Ab0LSQXC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 11:23:02 -0500
Received: by fxm18 with SMTP id 18so2274789fxm.2
        for <netdev@vger.kernel.org>; Sun, 19 Dec 2010 08:23:00 -0800 (PST)
In-Reply-To: <4D0E2E52.3090802@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/20 Pawe=C5=82 Staszewski <pstaszewski@itcare.pl>:
> W dniu 2010-12-19 16:43, Eric Dumazet pisze:
>>
>> Unfortunately, we miss the start of panic messages. Could you try to=
 get
>> them ?
>>
> In attached images
>

It seems the kernel panic at:

        if (skb_shared(skb))
                BUG();

in pskb_expand_head().

It maybe related to my patch:
http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commitdiff;h=3D210d6de78c5d7c785fc532556cea340e517955e1

You can try to revert it and test again.

However, the bug is a misuse of pskb_expand_head().

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
