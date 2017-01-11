From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv4: Fix multipath selection with vrf
Date: Wed, 11 Jan 2017 10:00:27 -0500 (EST)
Message-ID: <20170111.100027.559018351964620080.davem@davemloft.net>
References: <1484087855-4607-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938150AbdAKPA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:00:29 -0500
In-Reply-To: <1484087855-4607-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 10 Jan 2017 14:37:35 -0800

> fib_select_path does not call fib_select_multipath if oif is set in the
> flow struct. For VRF use cases oif is always set, so multipath route
> selection is bypassed. Use the FLOWI_FLAG_SKIP_NH_OIF to skip the oif
> check similar to what is done in fib_table_lookup.
> 
> Add saddr and proto to the flow struct for the fib lookup done by the
> VRF driver to better match hash computation for a flow.
> 
> Fixes: 613d09b30f8b ("net: Use VRF device index for lookups on TX")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> IPv6 multipath selection works fine as is.

Applied and queued up for -stable, thanks David.
