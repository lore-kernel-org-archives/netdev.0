From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: icmp_route_lookup should use rt dev to
 determine L3 domain
Date: Wed, 09 Nov 2016 18:50:28 -0500 (EST)
Message-ID: <20161109.185028.679053579853027999.davem@davemloft.net>
References: <1478548989-1832-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbcKIXua (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 18:50:30 -0500
In-Reply-To: <1478548989-1832-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  7 Nov 2016 12:03:09 -0800

> icmp_send is called in response to some event. The skb may not have
> the device set (skb->dev is NULL), but it is expected to have an rt.
> Update icmp_route_lookup to use the rt on the skb to determine L3
> domain.
> 
> Fixes: 613d09b30f8b ("net: Use VRF device index for lookups on TX")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David.
