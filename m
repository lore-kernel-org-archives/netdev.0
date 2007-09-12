From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6.24][NETNS][patch 3/3] fix bad macro definition
Date: Wed, 12 Sep 2007 05:58:07 -0700 (PDT)
Message-ID: <20070912.055807.35675297.davem@davemloft.net>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
	<20070912124429.288622995@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:38328
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966323AbXILM6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:58:50 -0400
In-Reply-To: <20070912124429.288622995@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dlezcano@fr.ibm.com
Date: Wed, 12 Sep 2007 14:38:14 +0200

> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> The macro definition is bad. When calling next_net_device with 
> parameter name "dev", the resulting code is:
> 	  struct net_device *dev = dev and that leads to an unexpected
> behavior. Especially when llc_core is compiled in, the kernel panics
> at boot time.
> The patchset change macro definition with static inline functions as
> they were defined before.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks.
