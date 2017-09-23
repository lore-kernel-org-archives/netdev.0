From: David Miller <davem@davemloft.net>
Subject: Re: tools: selftests: psock_tpacket: skip un-supported tpacket_v3
 test
Date: Fri, 22 Sep 2017 18:20:17 -0700 (PDT)
Message-ID: <20170922.182017.17747017677768533.davem@davemloft.net>
References: <20170922101717.11933-1-orson.zhai@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shuah@kernel.org, milosz.wasilewski@linaro.org,
        sumit.semwal@linaro.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: orson.zhai@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752004AbdIWBUS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 21:20:18 -0400
In-Reply-To: <20170922101717.11933-1-orson.zhai@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Orson Zhai <orson.zhai@linaro.org>
Date: Fri, 22 Sep 2017 18:17:17 +0800

> The TPACKET_V3 test of PACKET_TX_RING will fail with kernel version
> lower than v4.11. Supported code of tx ring was add with commit id
> <7f953ab2ba46: af_packet: TX_RING support for TPACKET_V3> at Jan. 3
> of 2017.
> 
> So skip this item test instead of reporting failing for old kernels.
> 
> Signed-off-by: Orson Zhai <orson.zhai@linaro.org>

The whole point is to make sure the kernel in which the selftest
code is present functions properly.

There are many tests in selftests that only work on recent kernels.

I'm not applying this, sorry.
