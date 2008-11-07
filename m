From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mark flow_cache_cpu_prepare() as __init
Date: Thu, 06 Nov 2008 23:07:59 -0800 (PST)
Message-ID: <20081106.230759.51179763.davem@davemloft.net>
References: <20081107034059.GA20845@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750861AbYKGHIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 02:08:00 -0500
In-Reply-To: <20081107034059.GA20845@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 7 Nov 2008 06:40:59 +0300

> It's called from __init code only. And__devinit in generic networking code
> is pretty strange :^)
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I believe the history of this is that we used to call this thing
as a CPU hotplug operation, and at the time that was the appropriate
marker to use for such things.

Applied to net-next-2.6, thanks!
