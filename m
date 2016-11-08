From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: icmp6_send should use dst dev to determine L3
 domain
Date: Mon, 07 Nov 2016 20:31:06 -0500 (EST)
Message-ID: <20161107.203106.1546467770572047915.davem@davemloft.net>
References: <1478215046-18806-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752431AbcKHBbI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 20:31:08 -0500
In-Reply-To: <1478215046-18806-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  3 Nov 2016 16:17:26 -0700

> icmp6_send is called in response to some event. The skb may not have
> the device set (skb->dev is NULL), but it is expected to have a dst set.
> Update icmp6_send to use the dst on the skb to determine L3 domain.
> 
> Fixes: ca254490c8dfd ("net: Add VRF support to IPv6 stack")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David.
