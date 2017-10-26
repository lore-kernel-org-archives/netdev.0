From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: fix overflow in collecting IBQ and OBQ
 dump
Date: Thu, 26 Oct 2017 17:32:04 +0900 (KST)
Message-ID: <20171026.173204.1119963564993171986.davem@davemloft.net>
References: <8b225c39b59b637a53c05d53d563d38fe989cbcd.1508853300.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: rahul.lakkireddy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932302AbdJZIcK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:32:10 -0400
In-Reply-To: <8b225c39b59b637a53c05d53d563d38fe989cbcd.1508853300.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Date: Tue, 24 Oct 2017 19:28:26 +0530

> Destination buffer already has offset added.  So, don't add offset
> again.
> 
> Fetch actual size of configured OBQ from hardware, instead of using
> hardcoded value.
> 
> Fixes: 7c075ce221cf ("cxgb4: collect IBQ and OBQ dumps")
> Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
