From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] ila: Cache a route in ILA lwt structure
Date: Sat, 15 Oct 2016 17:34:01 -0400 (EDT)
Message-ID: <20161015.173401.871906699367991045.davem@davemloft.net>
References: <20161014182537.1713757-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbcJOVeD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 17:34:03 -0400
In-Reply-To: <20161014182537.1713757-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 14 Oct 2016 11:25:35 -0700

> Add a dst_cache to ila_lwt structure. This holds a cached route for the
> translated address. In ila_output we now perform a route lookup after
> translation and if possible (destination in original route is full 128
> bits) we set the dst_cache. Subsequent calls to ila_output can then use
> the cache to avoid the route lookup.
 ...

Series applied, thanks Tom.
