From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: How to compile tcp fast open client app with kernel tfo client
 support ?
Date: Fri, 9 Nov 2012 12:17:30 -0800
Message-ID: <CAK3+h2xAqjs8CvkcwXiFryyQhDnohsN7-0KfQVjpegZh_AD1eg@mail.gmail.com>
References: <CAK3+h2xmgy+RhUy=MZ5Cu8Zpz+gQmt3dXCX0tpLAWFCTeujBLA@mail.gmail.com>
	<CAGK4HS-U+Ov5x8z+1CRZdiAD9MhfBUfurKKBbt1EWGYFLN8TcA@mail.gmail.com>
	<CAK3+h2z5=n6BHGzPjfbrJS4MbVGQ2pdMQP54dOZ8M=8xigUd3Q@mail.gmail.com>
	<CAK6E8=fc=hYppk=4+tnNF9UPvQNFhw8YKo-ebG2y6FwXTft_EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33258 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848Ab2KIURb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 15:17:31 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so6505561iea.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 12:17:30 -0800 (PST)
In-Reply-To: <CAK6E8=fc=hYppk=4+tnNF9UPvQNFhw8YKo-ebG2y6FwXTft_EQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Vincent,
>
> Note that MSG_FASTOPEN flag should be used only once. Subsequent
> sendto(MSG_FASTOPEN) == connect() on connected sockets. You can verify
> if the fast open is successful by checking a bit in TCP_INFO.
> http://patchwork.o zlabs.org/patch/192883/ if you are running a fresh
> netdev build.
>
> I'll submit a patch to update the man page on MSG_FASTOPEN too.
>
> Yuchung
>

I have tried to run fresh build net-next, for some reason the build
stops ssh service from starting up, tried 3.7.0-rc4 too, same issue. I
don't know if it is new kernel bug or ubuntu upstart bug, but that is
another issue.

I will study the tcp fast open more, thanks.

Vincent
