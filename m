From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: preserve ACK clocking in TSO
Date: Fri, 22 Mar 2013 07:52:30 -0700
Message-ID: <1363963950.4431.65.camel@edumazet-glaptop>
References: <1363923369.4431.53.camel@edumazet-glaptop>
	 <20130322.103435.879689479406836333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
	nanditad@google.com, vanj@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:64828 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932719Ab3CVOwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:52:33 -0400
Received: by mail-da0-f43.google.com with SMTP id u36so2313874dak.2
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 07:52:33 -0700 (PDT)
In-Reply-To: <20130322.103435.879689479406836333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 10:34 -0400, David Miller wrote:

> I always wondered about this, good catch.
> 
> Applied and queued up for -stable, thanks!

It took me a while to see the light.

I was trying to reduce the time limit (2 ticks -> 1 tick), or remove
tso_deferred field to use lsndtime instead.

Then, before cooking the patch for net-next, I finally understood the
problem.

Thanks
