From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] netns: fix error code when the nsid is
 already used
Date: Sat, 10 Jun 2017 15:59:24 -0400 (EDT)
Message-ID: <20170610.155924.632737973845428746.davem@davemloft.net>
References: <1497012117-1344-1-git-send-email-nicolas.dichtel@6wind.com>
        <1497012117-1344-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33214 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdFJT7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 15:59:31 -0400
In-Reply-To: <1497012117-1344-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  9 Jun 2017 14:41:57 +0200

> When the user tries to assign a specific nsid, idr_alloc() is called with
> the range [nsid, nsid+1]. If this nsid is already used, idr_alloc() returns
> ENOSPC (No space left on device). In our case, it's better to return
> EEXIST to make it clear that the nsid is not available.
> 
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
