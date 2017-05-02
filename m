From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net/ipv6: use-after-free in __call_rcu/in6_dev_finish_destroy_rcu
Date: Tue, 2 May 2017 11:22:32 -0600
Message-ID: <d377e00e-4aca-8ee9-9106-4f8912dfb458@cumulusnetworks.com>
References: <CAAeHK+y=YqG0Kb2chQ=_2E8aPttMetQjZPCxFibHKCfktQS2PQ@mail.gmail.com>
 <20170426135950.GO3956@linux.vnet.ibm.com>
 <CAAeHK+yzuh7mAmLR9DgHsLYBykqD8YhFcv=Nx6Az_f+PV_YMzw@mail.gmail.com>
 <e133f72f-89ab-bf45-67f5-4ad0c502adc4@cumulusnetworks.com>
 <CAAeHK+z-LFc1mbg3FKtSnMqLGQf2kr432a-MSeMx8Q7epfnVaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+z-LFc1mbg3FKtSnMqLGQf2kr432a-MSeMx8Q7epfnVaw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/2/17 10:58 AM, Andrey Konovalov wrote:
> Do you have a patch that I could test?

not yet.

> 
> I also reported another issue recently, that might also be related to this one:
> https://groups.google.com/forum/#!topic/syzkaller/Rt0pgY4wfiw

different problem. I can still trigger this one with the reproducer you sent
