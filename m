From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: make congestion control optionally skip slow
 start after idle
Date: Mon, 08 May 2017 14:37:59 -0400 (EDT)
Message-ID: <20170508.143759.420967359752096993.davem@davemloft.net>
References: <20170505195323.124792-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
        edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751191AbdEHSiC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 14:38:02 -0400
In-Reply-To: <20170505195323.124792-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri,  5 May 2017 12:53:23 -0700

> From: Wei Wang <weiwan@google.com>
> 
> Congestion control modules that want full control over congestion
> control behavior do not want the cwnd modifications controlled by
> the sysctl_tcp_slow_start_after_idle code path.
> So skip those code paths for CC modules that use the cong_control()
> API.
> As an example, those cwnd effects are not desired for the BBR congestion
> control algorithm.
> 
> Fixes: c0402760f565 ("tcp: new CC hook to set sending rate with rate_sample in any CA state")
> Signed-off-by: Wei Wang <weiwan@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks.
