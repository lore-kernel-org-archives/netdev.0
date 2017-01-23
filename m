From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: Check that idev is non-NULL in
 rt6_fill_node
Date: Sun, 22 Jan 2017 23:32:39 -0500 (EST)
Message-ID: <20170122.233239.720617884825007357.davem@davemloft.net>
References: <1485144480-4460-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaolong.ye@intel.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750731AbdAWEck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 23:32:40 -0500
In-Reply-To: <1485144480-4460-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 22 Jan 2017 20:08:00 -0800

> The ipv6 route dump code passes ip6_null_entry to rt6_fill_node.

Doesn't this fact cause you to take a pause?

I can't see a legitimate reason to dump the null entry, it's
a marker rather than a real entry.
