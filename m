From: David Miller <davem@davemloft.net>
Subject: Re: UDP sockets oddities
Date: Fri, 25 Aug 2017 21:17:24 -0700 (PDT)
Message-ID: <20170825.211724.1703031815383559958.davem@davemloft.net>
References: <ce4af8cc-3de1-a777-967c-a57103994e1d@gmail.com>
        <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
        <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, pabeni@redhat.com,
        willemb@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750728AbdHZER3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 00:17:29 -0400
In-Reply-To: <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 25 Aug 2017 20:25:26 -0700

> It would. Since the call trace involves udp_send_skb() how come we are
> not returning an error to write(2)? are there other code paths where the
> neighbor code can do drops like these?

Keep in mind that the neighbour code isn't dropping the current 'skb'
coming from the IP stack, it's dropping the oldest packet in the
resolution queue.
