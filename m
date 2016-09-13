From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] cxgb4: add support for offloading TC u32
 filters
Date: Tue, 13 Sep 2016 12:12:57 -0400 (EDT)
Message-ID: <20160913.121257.1557877495657097138.davem@davemloft.net>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: rahul.lakkireddy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753312AbcIMQM6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 12:12:58 -0400
In-Reply-To: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Date: Mon, 12 Sep 2016 13:42:33 +0530

> This series of patches add support to offload TC u32 filters onto
> Chelsio NICs.
> 
> Patch 1 moves current common filter code to separate files
> in order to provide a common api for performing packet classification
> and filtering in Chelsio NICs.
> 
> Patch 2 enables filters for normal NIC configuration and implements
> common api for setting and deleting filters.
> 
> Patch 3 provides a debugfs for dumping filter information.
> 
> Patches 4-7 add support for TC u32 offload via ndo_setup_tc.

Like Jiri I'm getting increasingly disappointed how liberally people
toss tons of things into debugfs.

This seems to be the way driver developers throw their hands into the
air when they can't find a quick and easy way to export some piece of
information.

Please work on the long term usability of the kernel and all
networking drivers by finding a bonafide piece of existing
infrastructure by which to export things, or build a new one if
needed.

Thanks.
