From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix link statistics counter errors
Date: Sun, 27 Nov 2016 20:37:36 -0500 (EST)
Message-ID: <20161127.203736.1937105888251361121.davem@davemloft.net>
References: <1480088102-31516-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, maloy@donjonn.com,
        tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752439AbcK1Bhi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 20:37:38 -0500
In-Reply-To: <1480088102-31516-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 25 Nov 2016 10:35:02 -0500

> In commit e4bf4f76962b ("tipc: simplify packet sequence number
> handling") we changed the internal representation of the packet
> sequence number counters from u32 to u16, reflecting what is really
> sent over the wire.
> 
> Since then some link statistics counters have been displaying incorrect
> values, partially because the counters meant to be used as sequence
> number snapshots are now used as direct counters, stored as u32, and
> partially because some counter updates are just missing in the code.
> 
> In this commit we correct this in two ways. First, we base the
> displayed packet sent/received values on direct counters instead
> of as previously a calculated difference between current sequence
> number and a snapshot. Second, we add the missing updates of the
> counters.
> 
> This change is compatible with the current netlink API, and requires
> no changes to the user space tools.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
