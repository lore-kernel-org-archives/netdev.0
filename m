From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH] ipv4: Namespaceify tcp_max_orphans knob
Date: Sat, 9 Sep 2017 09:25:40 +0800
Message-ID: <798CA25A-CA09-4D06-A9B6-7C5791A6EEC1@cmss.chinamobile.com>
References: <1504753808-13266-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAM_iQpV4gRwhT4VXPtJft38ixG6xE3PF9z4gB7HHJEUsqbCtOw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpV4gRwhT4VXPtJft38ixG6xE3PF9z4gB7HHJEUsqbCtOw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 2017年9月9日, at 上午6:13, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> 
> On Wed, Sep 6, 2017 at 8:10 PM, Haishuang Yan
> <yanhaishuang@cmss.chinamobile.com> wrote:
>> Different namespace application might require different maximal number
>> of TCP sockets independently of the host.
> 
> So after your patch we could have N * net->ipv4.sysctl_tcp_max_orphans
> in a whole system, right? This just makes OOM easier to trigger.
> 

>From my understanding, before the patch, we had N * net->ipv4.sysctl_tcp_max_orphans,
and after the patch, we could have ns1.sysctl_tcp_max_orphans + ns2.sysctl_tcp_max_orphans
+ ns3.sysctl_tcp_max_orphans, is that right? Thanks for your reviewing.
