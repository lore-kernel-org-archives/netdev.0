From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from
 userspace
Date: Wed, 12 Dec 2012 08:15:00 -0800
Message-ID: <20121212081500.24085752@nehalam.linuxnetplumber.net>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54340 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753528Ab2LLQQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 11:16:22 -0500
In-Reply-To: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 11:58:03 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> This is basically a repost of my previous patchset:
> "[patch net-next-2.6 0/2] net: allow to change carrier via sysfs" from Aug 30
> 
> The way net-sysfs stores values changed and this patchset reflects it.
> Also, I exposed carrier via rtnetlink iface.
> 
> So far, only dummy driver uses carrier change ndo. In very near future
> team driver will use that as well.
> 
> Jiri Pirko (4):
>   net: add change_carrier netdev op
>   net: allow to change carrier via sysfs
>   rtnl: expose carrier value with possibility to set it
>   dummy: implement carrier change
> 
>  drivers/net/dummy.c          | 10 ++++++++++
>  include/linux/netdevice.h    |  7 +++++++
>  include/uapi/linux/if_link.h |  1 +
>  net/core/dev.c               | 19 +++++++++++++++++++
>  net/core/net-sysfs.c         | 15 ++++++++++++++-
>  net/core/rtnetlink.c         | 10 ++++++++++
>  6 files changed, 61 insertions(+), 1 deletion(-)
> 

I needed to do the same thing for a project we are working on and discovered
that there already is a working documented interface for doing that via
operstate mode. Therefore I can't recommend that the additional complexity
of a new API for this is required.
