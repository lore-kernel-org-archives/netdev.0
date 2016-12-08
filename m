From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: do not read sk_drops if application does
 not care
Date: Thu, 08 Dec 2016 13:31:24 -0500 (EST)
Message-ID: <20161208.133124.1404435790534805233.davem@davemloft.net>
References: <1481133936.4930.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbcLHSbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:31:25 -0500
In-Reply-To: <1481133936.4930.51.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Dec 2016 10:05:36 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> sk_drops can be an often written field, do not read it unless
> application showed interest.
> 
> Note that sk_drops can be read via inet_diag, so applications
> can avoid getting this info from every received packet.
> 
> In the future, 'reading' sk_drops might require folding per node or per
> cpu fields, and thus become even more expensive than today.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
