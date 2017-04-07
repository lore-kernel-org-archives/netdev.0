From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 7 Apr 2017 08:46:30 -0700
Message-ID: <CAM_iQpWYP4cVr6xeWUnL08uLNDRDU_mAhiN7SinftTg+ZG293g@mail.gmail.com>
References: <20170407101202.30ec5a4e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jiri Kosina <jkosina@suse.cz>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170407101202.30ec5a4e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 6, 2017 at 5:12 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> diff --cc net/sched/sch_generic.c
> index 1a2f9e964330,3e64d23e098c..000000000000
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@@ -794,8 -794,8 +794,8 @@@ static void attach_default_qdiscs(struc
>                 }
>         }
>   #ifdef CONFIG_NET_SCHED
>  -      if (dev->qdisc)
>  +      if (dev->qdisc != &noop_qdisc)
> -               qdisc_hash_add(dev->qdisc);
> +               qdisc_hash_add(dev->qdisc, false);
>   #endif
>   }


Looks good to me.

Thanks.
