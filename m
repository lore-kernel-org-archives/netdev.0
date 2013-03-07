From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool
 get/set phy setting
Date: Thu, 7 Mar 2013 19:59:10 +0000
Message-ID: <1362686350.2936.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
	 <1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
	 <8762135on4.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32542 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932694Ab3CGT70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 14:59:26 -0500
In-Reply-To: <8762135on4.fsf@dell.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-07 at 14:24 +0100, Peter Korsgaard wrote:
> >>>>> "M" == Mugunthan V N <mugunthanvnm@ti.com> writes:
> 
>  M> This patch implements get/set of the phy settings via ethtool apis
>  M> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>  M> ---
>  M>  Documentation/devicetree/bindings/net/cpsw.txt |    3 +++
>  M>  drivers/net/ethernet/ti/cpsw.c                 |   32 ++++++++++++++++++++++++
>  M>  include/linux/platform_data/cpsw.h             |    1 +
>  M>  3 files changed, 36 insertions(+)
> 
>  M> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>  M> index ecfdf75..8d61300 100644
>  M> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>  M> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>  M> @@ -20,6 +20,7 @@ Required properties:
>  M>  - cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
>  M>  - phy_id		: Specifies slave phy id
>  M>  - mac-address		: Specifies slave MAC address
>  M> +- ethtool-active-slave	: Specifies the slave to use for ethtool command
> 
> That again sounds like something Linux specific rather than a hardware
> property.

Yes, indeed.  Isn't it redundant with the phy_id?

Ben.

> It would be good if all these special things (dual emac mode, vlan
> handling, switching) could be handled using the existing kernel
> (bridging/vlan) infrastructure, and the driver always just exposing 2
> network interfaces instead of these configuration properties.
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
