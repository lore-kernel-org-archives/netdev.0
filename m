From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_condense() can also deal with empty
 skbs
Date: Fri, 09 Dec 2016 23:07:26 -0500 (EST)
Message-ID: <20161209.230726.1585713028238746506.davem@davemloft.net>
References: <1481299325.4930.183.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbcLJEH1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 23:07:27 -0500
In-Reply-To: <1481299325.4930.183.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Dec 2016 08:02:05 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems attackers can also send UDP packets with no payload at all.
> 
> skb_condense() can still be a win in this case.
> 
> It will be possible to replace the custom code in tcp_add_backlog()
> to get full benefit from skb_condense()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
