From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Is 3.18 patch "The tcp: TSO packets automatic sizing" will
 cause to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Tue, 06 May 2014 09:41:14 -0700
Message-ID: <1399394474.15399.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
	 <1399393821.15399.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: V JobNickname <workofv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:48116 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbaEFQlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:41:17 -0400
Received: by mail-pa0-f44.google.com with SMTP id ld10so6162498pab.17
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 09:41:16 -0700 (PDT)
In-Reply-To: <1399393821.15399.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-06 at 09:30 -0700, Eric Dumazet wrote:

> I cant see any effect for this patch explaining a 50% reduction in
> speed, unless a special qdisc setup maybe.

Oh wait, a buggy driver could explain the problem.

Some drivers really expected TX completion to happen as a side effect of
subsequent transmits.

You'll have to give more details on the configuration you are using.
