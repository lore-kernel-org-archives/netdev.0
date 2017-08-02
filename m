From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_data_queue() cleanup
Date: Wed, 02 Aug 2017 10:45:46 -0700 (PDT)
Message-ID: <20170802.104546.917280850887457216.davem@davemloft.net>
References: <1501596164.25002.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752593AbdHBRpr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:45:47 -0400
In-Reply-To: <1501596164.25002.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Aug 2017 07:02:44 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit c13ee2a4f03f ("tcp: reindent two spots after prequeue removal")
> removed code in tcp_data_queue().
> 
> We can go a little farther, removing an always true test,
> and removing initializers for fragstolen and eaten variables.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Series applied, thanks!
