From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] tcp: sender chronographs instrumentation
Date: Mon, 28 Nov 2016 16:19:06 -0500 (EST)
Message-ID: <20161128.161906.1900426045355871354.davem@davemloft.net>
References: <1480191016-73210-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soheil@google.com, francisyyan@gmail.com, netdev@vger.kernel.org,
        ncardwell@google.com, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753105AbcK1VTI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:19:08 -0500
In-Reply-To: <1480191016-73210-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Sat, 26 Nov 2016 12:10:10 -0800

> This patch set provides instrumentation on TCP sender limitations.
> While developing the BBR congestion control, we noticed that TCP
> sending process is often limited by factors unrelated to congestion
> control: insufficient sender buffer and/or insufficient receive
> window/buffer to saturate the network bandwidth. Unfortunately these
> limits are not visible to the users and often the poor performance
> is attributed to the congestion control of choice.
> 
> Thie patch aims to help users get the high level understanding of
> where sending process is limited by, similar to the TCP_INFO design.
> It is not to replace detailed kernel tracing and instrumentation
> facilities.
> 
> In addition this patch set provides a new option to the timestamping
> work to instrument these limits on application data unit. For exampe,
> one can use SO_TIMESTAMPING and this patch set to measure the how
> long a particular HTTP response is limited by small receive window.
> 
> Patch set was initially written by Francis Yan then polished
> by Yuchung Cheng, with lots of help from Eric Dumazet and Soheil
> Hassas Yeganeh.

Looks great, series applied, thanks!
