From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: Add extack messages for newlink
 failures
Date: Mon, 07 Aug 2017 15:16:52 -0700 (PDT)
Message-ID: <20170807.151652.231418992480952915.davem@davemloft.net>
References: <1502125690-2212-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37198 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbdHGWRD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 18:17:03 -0400
In-Reply-To: <1502125690-2212-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon,  7 Aug 2017 10:08:10 -0700

> Add extack error messages for failure paths creating vrf devices. Once
> extack support is added to iproute2, we go from the unhelpful:
>     $  ip li add foobar type vrf
>     RTNETLINK answers: Invalid argument
> 
> to:
>     $ ip li add foobar type vrf
>     Error: VRF table id is missing
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied, thanks David.
