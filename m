From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] net: export netdev_txq_to_tc to allow sch_mqprio to
 compile as module
Date: Tue, 17 Oct 2017 04:21:24 -0700
Message-ID: <CANn89iJPRjokxHmj4dYnBQkJ=A4Z-7cMpZ34L+i949tJwUXd2g@mail.gmail.com>
References: <1508235010-4056-1-git-send-email-haustad@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsahern@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Willem de Bruijn <willemb@google.com>,
        John Fastabend <john.fastabend@gmail.com>,
        tcharding <me@tobin.cc>, LKML <linux-kernel@vger.kernel.org>,
        Henrik Austad <haustad@cisco.com>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
To: Henrik Austad <henrik@austad.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508235010-4056-1-git-send-email-haustad@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 3:10 AM, Henrik Austad <henrik@austad.us> wrote:
> In commit 32302902ff09 ("mqprio: Reserve last 32 classid values for HW
> traffic classes and misc IDs") sch_mqprio started using netdev_txq_to_tc
> to find the correct tc instead of dev->tc_to_txq[]
>
> However, when mqprio is compiled as a module, it cannot resolve the
> symbol, leading to this error:
>
>      ERROR: "netdev_txq_to_tc" [net/sched/sch_mqprio.ko] undefined!
>
> This adds an EXPORT_SYMBOL() since the other user in the kernel
> (netif_set_xps_queue) is also EXPORT_SYMBOL() (and not _GPL) or in a
> sysfs-callback.
>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Henrik Austad <haustad@cisco.com>


Reviewed-by: Eric Dumazet <edumazet@google.com>
