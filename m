From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: avoid disabling FEC by default
Date: Mon, 08 May 2017 15:01:41 -0400 (EDT)
Message-ID: <20170508.150141.852423881158703331.davem@davemloft.net>
References: <1494060906-6453-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, indranil@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35104 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751349AbdEHTBm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:01:42 -0400
In-Reply-To: <1494060906-6453-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Sat,  6 May 2017 14:25:06 +0530

> Recent Chelsio firmware started using few port capablity bits to
> manage FEC and as driver was not aware of FEC changes those bits
> were zeroed, consequently disabling FEC.
> 
> Avoid zeroing those bits and default to whatever the firmware
> tells us the Link is currently advertising.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
