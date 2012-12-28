From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next V3,repost 0/4] net: allow to change carrier from
 userspace
Date: Fri, 28 Dec 2012 11:18:05 -0200
Message-ID: <20121228131805.GB30336@obelix.rh>
References: <1356688180-3549-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445Ab2L1NSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 08:18:17 -0500
Content-Disposition: inline
In-Reply-To: <1356688180-3549-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2012 at 10:49:36AM +0100, Jiri Pirko wrote:
> This is basically a V3 of a repost of my previous patchset:
> "[patch net-next-2.6 0/2] net: allow to change carrier via sysfs" from Aug 30
> 
> The way net-sysfs stores values changed and this patchset reflects it.
> Also, I exposed carrier via rtnetlink iface.
> 
> So far, only dummy driver uses carrier change ndo. In very near future
> team driver will use that as well.
> 
> V2->V3:
>  - updated ndo_change_carrier comment by Dan Williams
> 
> V1->v2:
>  - added bigger comment to ndo and also note to operstate.txt documentation
>    stating the clear purpose of this iface
> 
> Jiri Pirko (4):
>   net: add change_carrier netdev op
>   net: allow to change carrier via sysfs
>   rtnl: expose carrier value with possibility to set it
>   dummy: implement carrier change
> 
>  Documentation/networking/operstates.txt |  4 ++++
>  drivers/net/dummy.c                     | 10 ++++++++++
>  include/linux/netdevice.h               | 12 ++++++++++++
>  include/uapi/linux/if_link.h            |  1 +
>  net/core/dev.c                          | 19 +++++++++++++++++++
>  net/core/net-sysfs.c                    | 15 ++++++++++++++-
>  net/core/rtnetlink.c                    | 10 ++++++++++
>  7 files changed, 70 insertions(+), 1 deletion(-)

I am using this patch series already with team.

Acked-by: Flavio Leitner <fbl@redhat.com>
