From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [NIU] Add support for Neptune FEM/NEM cards for
 C10 server blades
Date: Wed, 23 Apr 2008 18:30:22 -0700 (PDT)
Message-ID: <20080423.183022.52374157.davem@davemloft.net>
References: <200804231812.m3NICPCL047978@sr1-umpk-33.sfbay.sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matheos.worku@sun.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39206
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752749AbYDXBaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 21:30:24 -0400
In-Reply-To: <200804231812.m3NICPCL047978@sr1-umpk-33.sfbay.sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <matheos.worku@sun.com>
Date: Wed, 23 Apr 2008 10:17:40 -0700

> @@ -3243,6 +3245,7 @@ struct niu {
>  	struct timer_list		timer;
>  	const struct niu_phy_ops	*phy_ops;
>  	int				phy_addr;
> +	int hotplug_phy_present;
>  	struct niu_link_config		link_config;
>  
>  	struct work_struct		reset_task;

Using a full integer for boolean state is wasteful, please
just add another state flag to niu->flags

Thank you.
