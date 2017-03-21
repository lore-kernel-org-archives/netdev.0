From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: ipv4: add support for ECMP hash
 policy choice
Date: Tue, 21 Mar 2017 15:28:27 -0700 (PDT)
Message-ID: <20170321.152827.766970976582430978.davem@davemloft.net>
References: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
        <1489670880-12717-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, jkbs@redhat.com, edumazet@google.com,
        pch@ordbogen.com, stephen@networkplumber.org,
        nicolas.dichtel@6wind.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57740 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933010AbdCUW3R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 18:29:17 -0400
In-Reply-To: <1489670880-12717-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 16 Mar 2017 15:28:00 +0200

> This patch adds support for ECMP hash policy choice via a new sysctl
> called fib_multipath_hash_policy and also adds support for L4 hashes.
> The current values for fib_multipath_hash_policy are:
>  0 - layer 3 (default)
>  1 - layer 4
> If there's an skb hash already set and it matches the chosen policy then it
> will be used instead of being calculated (currently only for L4).
> In L3 mode we always calculate the hash due to the ICMP error special
> case, the flow dissector's field consistentification should handle the
> address order thus we can remove the address reversals.
> If the skb is provided we always use it for the hash calculation,
> otherwise we fallback to fl4, that is if skb is NULL fl4 has to be set.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks Nikolay.
