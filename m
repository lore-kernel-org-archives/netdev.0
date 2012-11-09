From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: How to compile tcp fast open client app with kernel tfo client
 support ?
Date: Fri, 09 Nov 2012 12:27:03 -0800
Message-ID: <1352492823.19779.825.camel@edumazet-glaptop>
References: <CAK3+h2xmgy+RhUy=MZ5Cu8Zpz+gQmt3dXCX0tpLAWFCTeujBLA@mail.gmail.com>
	 <CAGK4HS-U+Ov5x8z+1CRZdiAD9MhfBUfurKKBbt1EWGYFLN8TcA@mail.gmail.com>
	 <CAK3+h2z5=n6BHGzPjfbrJS4MbVGQ2pdMQP54dOZ8M=8xigUd3Q@mail.gmail.com>
	 <CAK6E8=fc=hYppk=4+tnNF9UPvQNFhw8YKo-ebG2y6FwXTft_EQ@mail.gmail.com>
	 <CAK3+h2xAqjs8CvkcwXiFryyQhDnohsN7-0KfQVjpegZh_AD1eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53457 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507Ab2KIU1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 15:27:08 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so3069161pbb.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 12:27:07 -0800 (PST)
In-Reply-To: <CAK3+h2xAqjs8CvkcwXiFryyQhDnohsN7-0KfQVjpegZh_AD1eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 12:17 -0800, Vincent Li wrote:

> I have tried to run fresh build net-next, for some reason the build
> stops ssh service from starting up, tried 3.7.0-rc4 too, same issue. I
> don't know if it is new kernel bug or ubuntu upstart bug, but that is
> another issue.
> 

Not sure Ubuntu 10.04 binaries can run a 3.7 kernel.

Some bug fixes in kernel need bug fixes in userland.

You could try a bisection ?
