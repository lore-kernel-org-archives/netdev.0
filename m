From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove bh disabling around
 percpu_counter accesses
Date: Fri, 20 Jan 2017 11:27:35 -0500 (EST)
Message-ID: <20170120.112735.1965338591020455561.davem@davemloft.net>
References: <1484917568.16328.110.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752422AbdATQ1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:27:36 -0500
In-Reply-To: <1484917568.16328.110.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jan 2017 05:06:08 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Shaohua Li made percpu_counter irq safe in commit 098faf5805c8
> ("percpu_counter: make APIs irq safe")
> 
> We can safely remove BH disable/enable sections around various
> percpu_counter manipulations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks great, applied, thanks Eric.
