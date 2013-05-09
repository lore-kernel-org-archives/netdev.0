From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Thu, 09 May 2013 06:46:58 -0700
Message-ID: <1368107218.13473.91.camel@edumazet-glaptop>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <kmfd2s$e2m$1@ger.gmane.org> <1368079301.13473.88.camel@edumazet-glaptop>
	 <kmfk9c$7g6$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <kmfk9c$7g6$1@ger.gmane.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-09 at 07:46 +0000, Cong Wang wrote:

> 
> Either it is not expected to use arch_spin_lock directly, or it has to
> provide a nop for non-IA64.

I suggest you check yourself ;)

# git grep -n arch_spin_lock_init
arch/ia64/include/asm/spinlock.h:19:#define arch_spin_lock_init(x)                      ((x)->lock = 0)

This definition is not used at all.

It should for consistency, and it's not a netfilter concern.



