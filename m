From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv6: addrconf: Fix recursive spin lock call
Date: Tue, 02 Feb 2016 06:06:40 -0800
Message-ID: <1454422000.7627.194.camel@edumazet-glaptop2.roam.corp.google.com>
References: <f323a260f8bc358412de59575b058cdf.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35565 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479AbcBBOGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 09:06:43 -0500
Received: by mail-pa0-f52.google.com with SMTP id ho8so99632211pac.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 06:06:43 -0800 (PST)
In-Reply-To: <f323a260f8bc358412de59575b058cdf.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-02 at 02:11 +0000, subashab@codeaurora.org wrote:
> A rcu stall with the following backtrace was seen on a system with
> forwarding, optimistic_dad and use_optimistic set. To reproduce,
> set these flags and allow ipv6 autoconf.
> 
> This occurs because the device write_lock is acquired while already
> holding the read_lock. Back trace below -

Acked-by: Eric Dumazet <edumazet@google.com>
