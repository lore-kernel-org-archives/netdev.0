From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net, sched: respect rcu grace period on cls destruction
Date: Mon, 28 Nov 2016 22:55:48 -0800
Message-ID: <CAM_iQpXk=3b_93aLYYRiEynW9ao6i-v0ah-XqvpBOn_zDf+PsA@mail.gmail.com>
References: <0d6d89f885033f1739e97f7f3372ae6e1db72892.1480204343.git.daniel@iogearbox.net>
 <CAM_iQpVRDnLM_Cmp63PVkpYtmdtNECP-2m89=DGdidkUYyHwug@mail.gmail.com>
 <583BF43C.4020103@iogearbox.net> <20161128104736.GX31360@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Roi Dayan <roid@mellanox.com>, ast@fb.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35063 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752510AbcK2G4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:56:10 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so27644697ioe.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 22:56:09 -0800 (PST)
In-Reply-To: <20161128104736.GX31360@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 2:47 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> RCU callbacks are always executed in softirq context, so yes, you do need
> to use something like a work struct.  (Or a wakeup to a kthread or
> whatever.)

Thanks for your information.
