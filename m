From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sr: remove cleanup flag and fix HMAC
 computation
Date: Fri, 03 Feb 2017 11:05:41 -0500 (EST)
Message-ID: <20170203.110541.1401279510396798868.davem@davemloft.net>
References: <1486031378-3899-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdBCQFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:05:45 -0500
In-Reply-To: <1486031378-3899-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Thu, 2 Feb 2017 11:29:38 +0100

> In the latest version of the IPv6 Segment Routing IETF draft [1] the
> cleanup flag is removed and the flags field length is shrunk from 16 bits
> to 8 bits. As a consequence, the input of the HMAC computation is modified
> in a non-backward compatible way by covering the whole octet of flags
> instead of only the cleanup bit. As such, if an implementation compatible
> with the latest draft computes the HMAC of an SRH who has other flags set
> to 1, then the HMAC result would differ from the current implementation.
> 
> This patch carries those modifications to prevent conflict with other
> implementations of IPv6 SR.
> 
> [1] https://tools.ietf.org/html/draft-ietf-6man-segment-routing-header-05
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied.
