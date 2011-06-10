From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: Re: [PATCH v2 2/5] net: ep93xx_eth: pass struct device to DMA API
 functions
Date: Fri, 10 Jun 2011 19:55:45 +0300
Message-ID: <20110610165545.GA2753@acer>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <c0ddfc297e0ea1e64e58cedd6552c6b2e52c5fe8.1307040443.git.mika.westerberg@iki.fi>
 <ADE657CA350FB648AAC2C43247A983F001F3820B8699@AUSP01VMBX24.collaborationhost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"kernel@wantstofly.org" <kernel@wantstofly.org>, rmallon@gmail.com
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:44510 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107Ab1FJQ6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 12:58:17 -0400
Received: by ewy4 with SMTP id 4so972408ewy.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 09:58:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ADE657CA350FB648AAC2C43247A983F001F3820B8699@AUSP01VMBX24.collaborationhost.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2011 at 06:40:21PM -0500, H Hartley Sweeten wrote:
> 
> I just noticed this macro in include/linux/netdevice.h
> 
> /* Set the sysfs physical device reference for the network logical device
>  * if set prior to registration will cause a symlink during initialization.
>  */
> #define SET_NETDEV_DEV(net, pdev)       ((net)->dev.parent = (pdev))
> 
> Is there anyway you could use that macro in the probe to save the platform_device
> (with it's associated device) instead of introducing a new struct device * in the
> private data?

Nice finding, thanks.

I'll look into that and send new version of the whole series soon.
