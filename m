From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: qualcomm: rmnet: Support recycling
 frames to real device
Date: Wed, 01 Nov 2017 11:55:22 +0900 (KST)
Message-ID: <20171101.115522.243537601846810293.davem@davemloft.net>
References: <1509136208-14768-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44378 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdKACzZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:55:25 -0400
In-Reply-To: <1509136208-14768-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Fri, 27 Oct 2017 14:30:08 -0600

> For deaggregation, the real device receives a large linear skb and
> passes it on to rmnet. rmnet creates new skbs from this large frame.
> 
> If the real device supports recycling, it does not need to allocate
> the large skbs during packet reception and can instead reuse them.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

I'm uncomfortable applying this until you also provide an example of
this skb->destructor mechanism actually being used in a driver.

Thank you.
