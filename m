From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vrf: Add missing Rx counters
Date: Tue, 03 Jan 2017 18:52:28 -0500 (EST)
Message-ID: <20170103.185228.569275214749682521.davem@davemloft.net>
References: <1483465075-15452-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58892 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759833AbdADAEY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 19:04:24 -0500
In-Reply-To: <1483465075-15452-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue,  3 Jan 2017 09:37:55 -0800

> The move from rx-handler to L3 receive handler inadvertantly dropped the
> rx counters. Restore them.
> 
> Fixes: 74b20582ac38 ("net: l3mdev: Add hook in ip and ipv6")
> Reported-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable.
