From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: sleeping function called from invalid context in net_enable_timestamp
Date: Wed, 1 Mar 2017 11:59:55 -0800
Message-ID: <CANn89iL8XLopw+grdzMW6_vabiQjKrVL_q-u4-b1XcL_uRAPUw@mail.gmail.com>
References: <CACT4Y+bHh=mzTXw1J8vxbzimrQULss16B=693T4SMcndoNoPPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bHh=mzTXw1J8vxbzimrQULss16B=693T4SMcndoNoPPg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 11:51 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>
> Hello,
>
> I've got the following report while running syzkaller fuzzer on
> e5d56efc97f8240d0b5d66c03949382b6d7e5570



Right, a listener is playing fool games.

We need to use a work queue for all net_enable_timestamp() invocations
