From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: drop non loopback packets claiming to
 originate from ::1
Date: Mon, 17 Apr 2017 15:09:57 -0400 (EDT)
Message-ID: <20170417.150957.2155713098994217559.davem@davemloft.net>
References: <20170414182243.24506-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755413AbdDQTJ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:09:58 -0400
In-Reply-To: <20170414182243.24506-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 14 Apr 2017 20:22:43 +0200

> We lack a saddr check for ::1. This causes security issues e.g. with acls
> permitting connections from ::1 because of assumption that these originate
> from local machine.
> 
> Assuming a source address of ::1 is local seems reasonable.
> RFC4291 doesn't allow such a source address either, so drop such packets.
> 
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
