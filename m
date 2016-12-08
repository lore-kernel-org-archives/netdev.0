From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rfs: add a jump label
Date: Thu, 08 Dec 2016 13:19:00 -0500 (EST)
Message-ID: <20161208.131900.434329215014851517.davem@davemloft.net>
References: <1481128150.4930.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752274AbcLHSTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:19:02 -0500
In-Reply-To: <1481128150.4930.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Dec 2016 08:29:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> RFS is not commonly used, so add a jump label to avoid some conditionals
> in fast path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, but I wonder how effective this will really be in the long run.
