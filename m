From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dccp: consistently use dccp_write_space()
Date: Sun, 04 Jun 2017 19:58:52 -0400 (EDT)
Message-ID: <20170604.195852.727811399844205302.davem@davemloft.net>
References: <1496415746.5031.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751202AbdFDX6x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 19:58:53 -0400
In-Reply-To: <1496415746.5031.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Jun 2017 08:02:26 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> DCCP uses dccp_write_space() for sk->sk_write_space method.
> 
> Unfortunately a passive connection (as provided by accept())
> is using the generic sk_stream_write_space() function.
> 
> Lets simply inherit sk->sk_write_space from the parent
> instead of forcing the generic one.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks Eric.
