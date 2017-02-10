From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 09 Feb 2017 20:48:11 -0500 (EST)
Message-ID: <20170209.204811.352646130146676206.davem@davemloft.net>
References: <CALx6S34qGUd7Zteo_sDdcXK69cOZUwiQ6wsbLfiyHW1K6gJn=A@mail.gmail.com>
        <20170209.173415.1198067959393786704.davem@davemloft.net>
        <CALx6S36ojsMZx-TW0cMCjvK07ffymPon8FDAVKMpmFRd8R-yYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdBJEQZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 23:16:25 -0500
In-Reply-To: <CALx6S36ojsMZx-TW0cMCjvK07ffymPon8FDAVKMpmFRd8R-yYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 9 Feb 2017 15:08:22 -0800

> Okay, how about this... I'll add a configuration option like
> XDP_ALLOW_OTHER_HOOKS. The default will be to disallow setting any
> hook other than a BPF. If it is set, then we'll accept other hooks
> to be run. This way mostly restrict the interface by default, but
> still allow experimentation with other hook types like I need with
> TXDP or maybe the netfilter guys might want to fastpath netfilter
> etc. When we we bring a working robust implementation to netdev that
> show clear benefits then we can add those to BPF as the "allowed"
> hooks at that time. So this strictly controls the interfaces, but
> still also allows room for innovation.

Anyone is allowed to "innovate" in their own private kernel tree.

But I'm not unleashing that upstream.

The only reason I accepted XDP is entirely because it is limited
in scope to eBPF.  All eBPF programs execute in finite time,
cannot loop, cannot deadlock, cannot access arbitrary pieces
of kernel memory and datastructures.

It is a well defined, constrained, and incredibly tightly controlled
execution environment for implementing policy, monitoring and control.
