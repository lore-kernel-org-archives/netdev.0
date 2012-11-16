From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: handle tcp_net_metrics_init() order-5 memory
 allocation failures
Date: Fri, 16 Nov 2012 11:08:22 -0800
Message-ID: <1353092902.10798.45.camel@edumazet-glaptop>
References: <1353022864.10798.6.camel@edumazet-glaptop>
	 <20121116.013940.813652515905883288.davem@davemloft.net>
	 <1353079913.10798.31.camel@edumazet-glaptop>
	 <CAKyRK=iKnoRZbjyEXSYbKoFq8=wtVKAJYTQYeE9y_84YevdagA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julien Tinnes <jln@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:33377 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193Ab2KPTIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 14:08:25 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so1261299dak.19
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 11:08:25 -0800 (PST)
In-Reply-To: <CAKyRK=iKnoRZbjyEXSYbKoFq8=wtVKAJYTQYeE9y_84YevdagA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-16 at 10:51 -0800, Julien Tinnes wrote:

> It happens when users start Chrome. Chrome will create one new network
> NS (for the sandbox).
> 
> This has been used for a few years now, but we had our first report in
> January of this year and we've been getting a few reports very
> recently at a rate that is starting to worry me (crbug.com/110756).
> 
> Thanks a lot for helping with this!

Thanks for bringing this issue to our attention !
