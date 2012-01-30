From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Deinline __nlmsg_put and genlmsg_put. -7k code on i386
 defconfig
Date: Mon, 30 Jan 2012 13:11:04 -0500 (EST)
Message-ID: <20120130.131104.1782962680660646529.davem@davemloft.net>
References: <4F2597D3.6050606@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F2597D3.6050606@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Sun, 29 Jan 2012 20:02:43 +0100

> This change also removes commented-out copy of __nlmsg_put
> which was last touched in 2005 with "Enable once all users
> have been converted" comment on top.
> 
>    text	   data	    bss	    dec	    hex	filename
> 8453183	 533115	1810804	10797102 a4c02e	vmlinux.o.before
> 8446103	 533115	1810804	10790022 a4a486	vmlinux.o
> 
> Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>

This doesn't apply to net-next, it appears it was corrupted by your
email client:

> -static __inline__ struct nlmsghdr *
> -__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len,
> -int flags)

It appears to have chopped up a long line here, for example.
