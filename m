From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: better validation of received ack
 sequences
Date: Thu, 25 May 2017 12:48:17 -0400 (EDT)
Message-ID: <20170525.124817.1960721450872387047.davem@davemloft.net>
References: <fbb92f49-5eca-f411-dcab-253d2a222623@science.ru.nl>
        <1495578286.6465.90.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: p.fiterau-brostean@science.ru.nl, netdev@vger.kernel.org,
        F.Vaandrager@cs.ru.nl, ncardwell@google.com, ycheng@google.com,
        soheil@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933221AbdEYQsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:48:19 -0400
In-Reply-To: <1495578286.6465.90.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 May 2017 15:24:46 -0700

> Add a FLAG_NO_CHALLENGE_ACK so that tcp_rcv_state_process()
> can choose to send a challenge ACK and discard the packet instead
> of wrongly change socket state.

Applied, but the tests end up being double-negatives so it might
have been easier to understand if the flag was a positive rather
than a negative value.
