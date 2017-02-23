From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: Fix bpf_xdp_event_output
Date: Thu, 23 Feb 2017 13:56:03 -0500 (EST)
Message-ID: <20170223.135603.1948120117718577342.davem@davemloft.net>
References: <1487875234-886444-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, daniel@iogearbox.net
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751594AbdBWS4Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 13:56:16 -0500
In-Reply-To: <1487875234-886444-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 23 Feb 2017 10:40:34 -0800

> Fix a typo. xdp->data instead of xdp should be copied to the perf-event's
> dst_buff.
> 
> Fixes: 4de16969523c ("bpf: enable event output helper also for xdp types")
> Reported-by: Huapeng Zhou <hzhou@fb.com>
> Tested-by: Feixiong Zhang <feixiong@fb.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied, thanks.
