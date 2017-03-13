From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v1] vxlan: use appropriate family on L3 miss
Date: Sun, 12 Mar 2017 23:31:23 -0700 (PDT)
Message-ID: <20170312.233123.995363374133039457.davem@davemloft.net>
References: <20170310153024.30894-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, aduyck@mirantis.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org
To: vincent@bernat.im
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53758 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdCMGbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:31:25 -0400
In-Reply-To: <20170310153024.30894-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <vincent@bernat.im>
Date: Fri, 10 Mar 2017 16:30:24 +0100

> When sending a L3 miss, the family is set to AF_INET even for IPv6. This
> causes userland (eg "ip monitor") to be confused. Ensure we send the
> appropriate family in this case. For L2 miss, keep using AF_INET.
> 
> Signed-off-by: Vincent Bernat <vincent@bernat.im>

Applied, thank you.
