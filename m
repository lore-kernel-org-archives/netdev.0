From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sr: fix out-of-bounds access in SRH
 validation
Date: Thu, 20 Apr 2017 15:41:28 -0400 (EDT)
Message-ID: <20170420.154128.559189271397747152.davem@davemloft.net>
References: <20170418155949.1028-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48256 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947119AbdDTTla (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:41:30 -0400
In-Reply-To: <20170418155949.1028-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Tue, 18 Apr 2017 17:59:49 +0200

> This patch fixes an out-of-bounds access in seg6_validate_srh() when the
> trailing data is less than sizeof(struct sr6_tlv).
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied, but please provide a proper Fixes: tag next time.
