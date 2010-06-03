From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
	possible after transfer
Date: Thu, 3 Jun 2010 18:54:40 +0800
Message-ID: <AANLkTik-1cjIr6urrQg5RuyAVa_pf_GJS3UJ3JcfvQMb@mail.gmail.com>
References: <1275536881.18536.5.camel@eight.analog.com>
	<1275537919.29413.55.camel@edumazet-laptop>
	<AANLkTinrW2w9x6dbzTAzSrElqUueFOC6tJaPNsVcnLBv@mail.gmail.com>
	<1275556749.2456.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64813 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845Ab0FCKym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:54:42 -0400
Received: by gye5 with SMTP id 5so2959722gye.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 03:54:40 -0700 (PDT)
In-Reply-To: <1275556749.2456.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> As I said, core network takes care of three counters only, because it
> was 'free', as they share a cache line with a spinlock we must hold when
> calling xmit function.
>
> In receive path, we dont dirty a cache line in core network, so updating
> counters would add a cost. (modern NICs handle stats in firmware)
>
That's really resolve my doubts about lack of RX stats in kernel stack.

Thanks Eric.

-- 
--Junchang
