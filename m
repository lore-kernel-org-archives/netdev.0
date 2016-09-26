From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] bnx2x: page allocation failure
Date: Mon, 26 Sep 2016 09:46:06 -0400 (EDT)
Message-ID: <20160926.094606.142250516441125849.davem@davemloft.net>
References: <cover.1474577624.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
        Yuval.Mintz@qlogic.com
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935875AbcIZNqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 09:46:19 -0400
In-Reply-To: <cover.1474577624.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Thu, 22 Sep 2016 17:12:24 -0400

> While configuring ~500 multicast addrs, we ran into high order
> page allocation failures. They don't need to be high order, and
> thus I'm proposing to split them into at most PAGE_SIZE allocations.
> 
> Below is a sample failure.
 ...
> v2:
>  -make use of list_next_entry()
>  -only use PAGE_SIZE allocations

Series applied, thanks Jason.
