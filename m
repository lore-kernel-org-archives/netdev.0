From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: sleeping function called from invalid context in
 net_enable_timestamp
Date: Wed, 01 Mar 2017 12:11:59 -0800
Message-ID: <1488399119.9415.304.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+bHh=mzTXw1J8vxbzimrQULss16B=693T4SMcndoNoPPg@mail.gmail.com>
         <CANn89iL8XLopw+grdzMW6_vabiQjKrVL_q-u4-b1XcL_uRAPUw@mail.gmail.com>
         <1488398879.9415.302.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34973 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdCAUO5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 15:14:57 -0500
In-Reply-To: <1488398879.9415.302.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-01 at 12:07 -0800, Eric Dumazet wrote:
> On Wed, 2017-03-01 at 11:59 -0800, Eric Dumazet wrote:
> > On Wed, Mar 1, 2017 at 11:51 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > >
> > > Hello,
> > >
> > > I've got the following report while running syzkaller fuzzer on
> > > e5d56efc97f8240d0b5d66c03949382b6d7e5570
> > 
> > 
> > 
> > Right, a listener is playing fool games.
> > 
> > We need to use a work queue for all net_enable_timestamp() invocations
> 
> Something like :

We need something better, I will send a patch keeping good performance
for this jump label thing.
