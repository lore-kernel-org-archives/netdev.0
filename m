From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 22:16:13 +0200
Message-ID: <200702132216.13828.hasso@estpak.ee>
References: <200702131529.04708.hasso@estpak.ee> <20070213090224.2826859f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hax.kala.ee ([194.126.124.39]:44389 "HELO hax.kala.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750944AbXBMUQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 15:16:25 -0500
In-Reply-To: <20070213090224.2826859f@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> > You can disable it in /proc/sys/net/ipv6/conf/default/... and then
> > reenable it on the interfaces that you actually want.

And YOSHIFUJI Hideaki answered to this:

> The point is:
> 
>  - Until we have live address(es), we do not create inet6_dev{} for that
>    device.
>  - We do NOT run DAD until the link is ready (netif_carrier_ok()).
> 
> This means, we do NOT have any addresses until the link is once up,
> and thus, because the sysctl entries live in inet6_dev{}, we do not
> install net.ipv6.conf.ethX from values of net.ipv6.conf.default until
> then.

Ie. to make it very clear - I can't reenable it on the interface before
the first "carrier up" event (cable is plugged on). That's the point -
AFAICS the only way I can configure interface differently than default is
via daemon listening interface events via netlink. I can't do it in any
way before.


regards,

-- 
Hasso Tepper
Elion Enterprises Ltd. [AS3249]
IP & Data Networking Expert
