From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] skb: Propagate pfmemalloc on skb from head page only
Date: Thu, 14 Mar 2013 15:34:09 +0100
Message-ID: <1363271649.29475.18.camel@edumazet-glaptop>
References: <5141D0C4.70409@parallels.com>
	 <1363270569.29475.11.camel@edumazet-glaptop>
	 <5141DD72.6030906@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Mel Gorman <mgorman@suse.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	stable@kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:51528 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab3CNOeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 10:34:14 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so1059909eek.8
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 07:34:12 -0700 (PDT)
In-Reply-To: <5141DD72.6030906@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 18:23 +0400, Pavel Emelyanov wrote:

> Presumably you're right, but I don't understand how :( In order to trigger
> this, we should have a huge page, that gets linked to an skb _before_ it
> enters the TCP receive path. How can this happen when doing sendmsg/recvmsg?

Not only huge pages.

network now uses order-3 pages in both transmit and receive paths.
