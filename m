From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: update latest firmware version
 supported
Date: Tue, 16 May 2017 15:53:08 -0400 (EDT)
Message-ID: <20170516.155308.1022881279018412401.davem@davemloft.net>
References: <1494948412-7818-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, indranil@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53050 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdEPTxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:53:10 -0400
In-Reply-To: <1494948412-7818-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue, 16 May 2017 20:56:52 +0530

> Change t4fw_version.h to update latest firmware version
> number to 1.16.43.0.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

People are hitting regressions in 'net' due to using firmware allowed
by the current defines in combination with the FEC disabling commit.

So it doesn't make sense to "fix" this in 'net-next'.
