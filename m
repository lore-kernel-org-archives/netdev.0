From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] TX max rate limiting for Chelsio T4/T5
 adapters
Date: Mon, 22 Aug 2016 18:29:27 -0700 (PDT)
Message-ID: <20160822.182927.1597662957004774218.davem@davemloft.net>
References: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: rahul.lakkireddy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47345 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753509AbcHWB32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 21:29:28 -0400
In-Reply-To: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Date: Mon, 22 Aug 2016 16:29:05 +0530

> This series of patches implement tx max rate limiting per queue on
> Chelsio T4/T5 hardware.  This is achieved by first creating a tx
> scheduling class with the specified max rate.  The queue is then
> bound to the newly created class.  If a scheduling class with similar
> max rate already exists, then the queue is bound to the matching class.
> 
> Patch 1 adds support for setting tx scheduling classes.
> Patch 2 adds support to bind/unbind queues to/from the scheduling classes.
> Patch 3 implements the set_tx_maxrate NDO.

Series applied, thanks.
