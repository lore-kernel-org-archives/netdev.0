From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] dynamic_queue_limit.h: Make the struct ___cacheline_aligned_on_smp
Date: Fri, 7 Dec 2012 07:55:59 -0800
Message-ID: <CAL4Wiip12_Frb64WGk419_YApOuckTa3Jtd-nVROodLFTqvacg@mail.gmail.com>
References: <1354892334.29937.14.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36394 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172Ab2LGP4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 10:56:02 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so1410521ieb.19
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 07:56:01 -0800 (PST)
In-Reply-To: <1354892334.29937.14.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/7 Joe Perches <joe@perches.com>:
> Given that the struct will always have limit at the start of
> a cacheline, why not make  struct ___cacheline_aligned_on_smp
> and make limit the first member?
>
> It could make other structs that use struct dql a bit more
> predictable or efficient to pack.
>
> (netdev_queue is size reduced from 256 to 192 on x86-32)
>

No, please.

Have you tested this on a range of hardware and check how it can hurt
performance ?
