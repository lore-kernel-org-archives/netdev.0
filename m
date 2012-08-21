From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 15:22:16 +0200
Message-ID: <1345555336.5158.493.camel@edumazet-glaptop>
References: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43236 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226Ab2HUNWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 09:22:21 -0400
Received: by bkwj10 with SMTP id j10so2184100bkw.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 06:22:20 -0700 (PDT)
In-Reply-To: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 15:05 +0200, Sylvain Munaut wrote:
> Hi,
> 
> I'm starting to wonder if it's not related to
> 46517008e1168dc926cf2c47d529efc07eca85c0 "ipv4: Kill
> ip_rt_frag_needed()."
> 
> Cheers,
> 
>     Sylvain

Hmm, most probably problem came with commit
ceb3320610d6f15ff20dd4c042b36473d77de76f
(ipv4: Kill routes during PMTU/redirect updates.)
