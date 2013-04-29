From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3] ipv6: Kill ipv6 dependency of icmpv6_send().
Date: Mon, 29 Apr 2013 01:46:06 +0000 (UTC)
Message-ID: <klkjcu$drc$1@ger.gmane.org>
References: <1366924110-3397-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60639 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756647Ab3D2BqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Apr 2013 21:46:18 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UWdAW-0002Cy-Km
	for netdev@vger.kernel.org; Mon, 29 Apr 2013 03:46:16 +0200
Received: from 182.241.5.9 ([182.241.5.9])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 03:46:16 +0200
Received: from xiyou.wangcong by 182.241.5.9 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 03:46:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Apr 2013 at 21:08 GMT, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/net/ipv6/ip6_icmp.c b/net/ipv6/ip6_icmp.c
> new file mode 100644
> index 0000000..4578e23
> --- /dev/null
> +++ b/net/ipv6/ip6_icmp.c
> @@ -0,0 +1,47 @@
> +#include <linux/export.h>
> +#include <linux/icmpv6.h>
> +#include <linux/mutex.h>
> +#include <linux/netdevice.h>
> +#include <linux/spinlock.h>
> +
> +#include <net/ipv6.h>
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +

I don't think we need #if IS_ENABLED(CONFIG_IPV6) inside
net/ipv6/ip6_icmp.c.
