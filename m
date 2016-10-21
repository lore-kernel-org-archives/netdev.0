From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: make default fifo qdiscs appear in the dump
Date: Fri, 21 Oct 2016 10:59:35 -0400 (EDT)
Message-ID: <20161021.105935.1907696543877061916.davem@davemloft.net>
References: <alpine.LNX.2.00.1610211024400.31629@cbobk.fhfr.pm>
        <1477049817.7065.56.camel@edumazet-glaptop3.roam.corp.google.com>
        <alpine.LNX.2.00.1610211450440.31629@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jhs@mojatatu.com, phil@nwl.cc,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jikos@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1610211450440.31629@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jikos@kernel.org>
Date: Fri, 21 Oct 2016 14:56:33 +0200 (CEST)

> I'd really like to unhide the default qdiscs, it makes little sense to be 
> inconsistent in this way.

Something that's been invisible for such a long time... there is no
way applications need or require this.

If some new ones do, they can ask for it via the netlink request
inside of a new netlink attribute or similar.

That makes everyone happy.
