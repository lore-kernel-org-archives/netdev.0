From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: handle no dst on skb in icmp6_send
Date: Mon, 28 Nov 2016 16:13:44 -0500 (EST)
Message-ID: <20161128.161344.1778661062306703117.davem@davemloft.net>
References: <1480301573-21183-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932334AbcK1VOA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:14:00 -0500
In-Reply-To: <1480301573-21183-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 27 Nov 2016 18:52:53 -0800

> Andrey reported the following while fuzzing the kernel with syzkaller:
 ...
> icmp6_send / icmpv6_send is invoked for both rx and tx paths. In both
> cases the dst->dev should be preferred for determining the L3 domain
> if the dst has been set on the skb. Fallback to the skb->dev if it has
> not. This covers the case reported here where icmp6_send is invoked on
> Rx before the route lookup.
> 
> Fixes: 5d41ce29e ("net: icmp6_send should use dst dev to determine L3 domain")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
