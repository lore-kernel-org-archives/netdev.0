From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: fix tcp_fastopen unaligned access complaints
 on sparc
Date: Fri, 13 Jan 2017 12:31:53 -0500 (EST)
Message-ID: <20170113.123153.1102439896232313596.davem@davemloft.net>
References: <1484259898-30719-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
        rob.gardner@oracle.com
To: shannon.nelson@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51166 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdAMRcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:32:13 -0500
In-Reply-To: <1484259898-30719-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Thu, 12 Jan 2017 14:24:58 -0800

> Fix up a data alignment issue on sparc by swapping the order
> of the cookie byte array field with the length field in
> struct tcp_fastopen_cookie, and making it a proper union
> to clean up the typecasting.
> 
> This addresses log complaints like these:
>     log_unaligned: 113 callbacks suppressed
>     Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360
>     Kernel unaligned access at TPC[9764ac] tcp_try_fastopen+0x2ec/0x360
>     Kernel unaligned access at TPC[9764c8] tcp_try_fastopen+0x308/0x360
>     Kernel unaligned access at TPC[9764e4] tcp_try_fastopen+0x324/0x360
>     Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> ---
> v2: Use Eric's suggestion for a union in the struct

Applied and queued up for -stable, thanks.
