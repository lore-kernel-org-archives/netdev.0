From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.9-rc1] handle error msg "driver changed  get_stats
 after register"
Date: Fri, 10 Sep 2004 18:01:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910180113.47d13658.davem@davemloft.net>
References: <20040911005507.62262.qmail@web40007.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Song Wang <wsonguci@yahoo.com>
In-Reply-To: <20040911005507.62262.qmail@web40007.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Sep 2004 17:55:07 -0700 (PDT)
Song Wang <wsonguci@yahoo.com> wrote:

> This patch is against 2.6.9-rc1.
> 
> In net/core/dev.c: dev_open
> 
>   if (get_stats_changed(dev) && net_ratelimit()) {
>                 printk(KERN_ERR "%s: driver changed
> get_stats after register\n",
>                        dev->name);
>         }

I think we should just get rid of this debugging hack,
we fixed all the drivers I think.

Stephen, what do you think?
