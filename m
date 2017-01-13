From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] netlink: do not enter direct reclaim from
 netlink_trim()
Date: Fri, 13 Jan 2017 09:20:50 -0800
Message-ID: <20170113172048.GA49247@ast-mbp.thefacebook.com>
References: <1484327482.13165.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35217 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750874AbdAMRUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:20:54 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so9185858pfa.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 09:20:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484327482.13165.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 09:11:22AM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In commit d35c99ff77ecb ("netlink: do not enter direct reclaim from
> netlink_dump()") we made sure to not trigger expensive memory reclaim.
> 
> Problem is that a bit later, netlink_trim() might be called and
> trigger memory reclaim.
> 
> netlink_trim() should be best effort, and really as fast as possible.
> Under memory pressure, it is fine to not trim this skb.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
