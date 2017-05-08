From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel: remove unreachable ICMP_REDIRECT code
Date: Mon, 08 May 2017 15:59:03 -0400 (EDT)
Message-ID: <20170508.155903.61649135414142419.davem@davemloft.net>
References: <1494241863-32549-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754321AbdEHT7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:59:05 -0400
In-Reply-To: <1494241863-32549-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Mon,  8 May 2017 19:11:03 +0800

> After call ip6_tnl_err(), the rel_type will be ether ICMPV6_DEST_UNREACH
> or ICMPV6_PKT_TOOBIG. We will never reach ICMP_REDIRECT. So remove it.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Your patches here, all seemingly due to "visual inspection", are starting
to really, truly, irritate me.

Half of them are unnecessary, some are completely buggy.

I have to review them and audit them very satrictly as a result, and
this takes up an unnecessarily large amount of my time.

Therefore, I'm basically going to stop looking at your changes _unless_
you can show that you specifically tested and exercised all of the code
paths you are changing.

I am sorry to have to do this, but the value to effort ratio of
reviewing and integrating your changes is quite poor.
