From: kuznet@ms2.inr.ac.ru
Subject: Re: MOD_{INC,SEC}_USE_COUNT() in net/ipv{4,6}
Date: Thu, 10 Apr 2003 06:54:38 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200304100254.GAA06560@sex.inr.ac.ru>
References: <20030409.180004.08009488.davem@redhat.com>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030409.180004.08009488.davem@redhat.com> from "David S. Miller" at Apr 9, 3 06:00:04 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>    This patch (against 2.5.67) converts MOD_{INC,DEC}_USE_COUNT in 
>    net/ipv{4,6} to try_module_get() and module_put().
> 
> Applied, but

Why not to delete this things instead? Calls of these functions from
inside of module is completely meaningless.

I remember I put them there just to mimic behaviour of another devices,
but it was just a mistake.

Alexey
