From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: remove unnecessary inet6_sk check
Date: Thu, 29 Dec 2016 12:06:09 -0500 (EST)
Message-ID: <20161229.120609.273388969622365315.davem@davemloft.net>
References: <20161228165318.5afrtlbulsgymc4c@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752734AbcL2RHJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:07:09 -0500
In-Reply-To: <20161228165318.5afrtlbulsgymc4c@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Wed, 28 Dec 2016 11:53:18 -0500

> np is already assigned in the variable declaration of ping_v6_sendmsg.
> At this point, we have already dereferenced np several times, so the
> NULL check is also redundant.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

Applied, thanks Dave.
