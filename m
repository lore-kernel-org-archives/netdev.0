From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH 1/3] drivers: of: add phy fixup support in DT
Date: Thu, 25 Apr 2013 17:09:25 +0100
Message-ID: <1366906165.2594.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
	 <1366654838-26479-2-git-send-email-mugunthanvnm@ti.com>
	 <20130425.035649.1109561373283256109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>, <linux-omap@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52940 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860Ab3DYQJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 12:09:29 -0400
In-Reply-To: <20130425.035649.1109561373283256109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 03:56 -0400, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Mon, 22 Apr 2013 23:50:36 +0530
> 
> > In earlier case phy fixup are added in board file as this is no more the case
> > so adding support for phy register fixup in Device Tree
> > 
> > Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> 
> When people put a series of undocumented PHY register writes using
> constants, we tell them it's firmware.
> 
> If these PHY registers are actually documented in the driver, write a
> function in that driver which does the programming sequence, then add
> a property that the driver looks for in order to determine whether to
> call that sequence or not.
> 
> I don't want people putting random PHY raw programming sequences and
> other crap like that into the OF device nodes.  It's extremely
> inelegant and inviting abuse.

I don't think booleans will be enough in general; a PHY may well require
link tuning for a specific board.  But the set of register addresses to
program is likely to be known in advance and then only the values would
belong in DT.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
