From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next] ipv6: avoid zeroing per cpu data again
Date: Mon, 9 Oct 2017 06:22:52 -0700
Message-ID: <20171009132252.GA3301751@devbig577.frc2.facebook.com>
References: <1507554097.31614.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:53528 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754640AbdJINWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 09:22:55 -0400
Received: by mail-qk0-f170.google.com with SMTP id w63so23527299qkd.10
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 06:22:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1507554097.31614.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 06:01:37AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> per cpu allocations are already zeroed, no need to clear them again.
> 
> Fixes: d52d3997f843f ("ipv6: Create percpu rt6_info")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Martin KaFai Lau <kafai@fb.com>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
