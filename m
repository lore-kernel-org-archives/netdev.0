From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] net/ncsi: NCSI Improvment and bug fixes
Date: Tue, 04 Oct 2016 02:13:25 -0400 (EDT)
Message-ID: <20161004.021325.1301099883976987002.davem@davemloft.net>
References: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54880 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751836AbcJDGN3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 02:13:29 -0400
In-Reply-To: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Tue,  4 Oct 2016 11:25:46 +1100

> This series of patches improves NCSI stack according to the comments
> I received after the NCSI code was merged to 4.8.rc1:
> 
>   * PATCH[1/8] fixes the build warning caused by xchg() with ia64-linux-gcc.
>     The atomic operations are removed. The NCSI's lock should be taken when
>     reading or updating its state and chained state.
>   * Channel ID (0x1f) is the reserved one and it cannot be valid channel ID.
>     So we needn't try to probe channel whose ID is 0x1f. PATCH[2/8] and
>     PATCH[3/8] are addressing this issue.
>   * The request IDs are assigned in round-robin fashion, but it's broken.
>     PATCH[4/8] make it work.
>   * PATCH[5/8] and PATCH[6/8] reworks the channel monitoring to improve the
>     code readability and its robustness.
>   * PATCH[7/8] and PATCH[8/8] introduces ncsi_stop_dev() so that the network
>     device can be closed and opened afterwards. No error will be seen.
> 
> Changelog
> =========
> v2:
>   * The NCSI's lock is taken when reading or updating its state as the
>     {READ,WRITE}_ONCE() isn't reliable.

Series applied, thanks.
