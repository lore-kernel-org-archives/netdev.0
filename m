From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Sun, 16 Dec 2012 11:54:51 +0100
Message-ID: <20121216105451.GA1546@minipsycho.orion>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46638 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458Ab2LPKy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 05:54:56 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so2702609eek.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 02:54:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I see that the patchset is in state "Rejected" in patchwork.
Stephen convinced me for a moment that the problem can be handled by operstate.
As it turned out (in last 3-4 emails in thread) operstate use would not
be an option.

So how should I proceed? Should I repost the patchset? Anyone has any other
comments?

thanks.

Wed, Dec 12, 2012 at 11:58:03AM CET, jiri@resnulli.us wrote:
>This is basically a repost of my previous patchset:
>"[patch net-next-2.6 0/2] net: allow to change carrier via sysfs" from Aug 30
>
>The way net-sysfs stores values changed and this patchset reflects it.
>Also, I exposed carrier via rtnetlink iface.
>
>So far, only dummy driver uses carrier change ndo. In very near future
>team driver will use that as well.
>
>Jiri Pirko (4):
>  net: add change_carrier netdev op
>  net: allow to change carrier via sysfs
>  rtnl: expose carrier value with possibility to set it
>  dummy: implement carrier change
>
> drivers/net/dummy.c          | 10 ++++++++++
> include/linux/netdevice.h    |  7 +++++++
> include/uapi/linux/if_link.h |  1 +
> net/core/dev.c               | 19 +++++++++++++++++++
> net/core/net-sysfs.c         | 15 ++++++++++++++-
> net/core/rtnetlink.c         | 10 ++++++++++
> 6 files changed, 61 insertions(+), 1 deletion(-)
>
>-- 
>1.8.0
>
