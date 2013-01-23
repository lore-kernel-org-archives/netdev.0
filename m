From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 09:13:05 -0800
Message-ID: <1358961185.12374.853.camel@edumazet-glaptop>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
	 <kdoibl$978$1@ger.gmane.org> <1358951180.12374.787.camel@edumazet-glaptop>
	 <CAJ4BwwG-fimMeSD_DSNZZz=Vjz3Qk_58qEnMGv_gmn0rTSeZAg@mail.gmail.com>
	 <1358960188.12374.830.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Yannick Koehler <yannick@koehler.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:41656 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976Ab3AWRNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 12:13:08 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so4895810pad.16
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 09:13:08 -0800 (PST)
In-Reply-To: <1358960188.12374.830.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 08:56 -0800, Eric Dumazet wrote:

> You'll have to add proper limits (SO_RCVBUF), accounting the truesize of
> all accumulated messages.

And if you claim being able to remove DOS attacks, you'll also have to
add global limits, at a very minimum.

(a la /proc/sys/net/ipv4/tcp_mem or /proc/sys/net/ipv4/udp_mem)

Its not an easy problem, unfortunately.
