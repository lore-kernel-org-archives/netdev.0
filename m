From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv4: Namespaceify tcp_max_orphans knob
Date: Fri, 8 Sep 2017 15:13:50 -0700
Message-ID: <CAM_iQpV4gRwhT4VXPtJft38ixG6xE3PF9z4gB7HHJEUsqbCtOw@mail.gmail.com>
References: <1504753808-13266-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504753808-13266-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 6, 2017 at 8:10 PM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> Different namespace application might require different maximal number
> of TCP sockets independently of the host.

So after your patch we could have N * net->ipv4.sysctl_tcp_max_orphans
in a whole system, right? This just makes OOM easier to trigger.
