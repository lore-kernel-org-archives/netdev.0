From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/6] ipv6 - make ip6_route_init to return an error code
Date: Fri, 07 Dec 2007 00:43:58 -0800 (PST)
Message-ID: <20071207.004358.233535756.davem@davemloft.net>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071206140303.281847428@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59994
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751780AbXLGIn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:43:59 -0500
In-Reply-To: <20071206140303.281847428@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 06 Dec 2007 14:53:33 +0100

> The route initialization function does not return any value to notify if
> the initialization is successful or not. This patch checks all calls made
> for the initilization in order to return a value for the caller.
> 
> Unfortunatly, proc_net_fops_create will return a NULL pointer if CONFIG_PROC_FS
> is off, so we can not check the return code without an ifdef CONFIG_PROC_FS 
> block in the ip6_route_init function.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks.
