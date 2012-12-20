From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V4 08/13] bridge: Add netlink interface to
 configure vlans on bridge ports
Date: Thu, 20 Dec 2012 07:48:55 +0000 (UTC)
Message-ID: <kauft7$u30$1@ger.gmane.org>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
 <1355939304-21804-9-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56924 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976Ab2LTHtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 02:49:16 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Tlash-0005RY-Vp
	for netdev@vger.kernel.org; Thu, 20 Dec 2012 08:49:27 +0100
Received: from 112.122.183.103 ([112.122.183.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 08:49:27 +0100
Received: from xiyou.wangcong by 112.122.183.103 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 08:49:27 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Dec 2012 at 17:48 GMT, Vlad Yasevich <vyasevic@redhat.com> wrote:
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index c30fe29..33bc740 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -23,6 +23,7 @@
>  #include <linux/if_ether.h>
>  #include <linux/slab.h>
>  #include <net/sock.h>
> +#include <linux/if_vlan.h>


Huh??


>  
>  #include "br_private.h"
>  
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index dead9df..84c6f04 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -16,6 +16,7 @@
>  #include <net/rtnetlink.h>
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
> +#include <uapi/linux/if_bridge.h>
>  

Please don't include UAPI headers directly, you should #include
<linux/if_bridge.h>.
