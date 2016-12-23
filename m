From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Fri, 23 Dec 2016 12:21:11 -0500 (EST)
Message-ID: <20161223.122111.1140847163936441075.davem@davemloft.net>
References: <20161222161622.o6gtidv24znbfs7n@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761344AbcLWRVM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 12:21:12 -0500
In-Reply-To: <20161222161622.o6gtidv24znbfs7n@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Thu, 22 Dec 2016 11:16:22 -0500

> By setting certain socket options on ipv6 raw sockets, we can confuse the
> length calculation in rawv6_push_pending_frames triggering a BUG_ON.
 ...
> Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

Applied and queued up for -stable, thanks Dave.
