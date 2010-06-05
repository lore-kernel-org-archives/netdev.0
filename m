From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2][v2] bonding: allow user-controlled
 output slave selection
Date: Sat, 05 Jun 2010 02:54:47 -0700 (PDT)
Message-ID: <20100605.025447.02296169.davem@davemloft.net>
References: <20100602184018.GL7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46398
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932734Ab0FEJyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:54:37 -0400
In-Reply-To: <20100602184018.GL7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 2 Jun 2010 14:40:18 -0400

> 
> v2: changed bonding module version, modified to apply on top of changes
> from previous patch in series, and updated documentation to elaborate on
> multiqueue awareness that now exists in bonding driver.
> 
> This patch give the user the ability to control the output slave for
> round-robin and active-backup bonding.  Similar functionality was
> discussed in the past, but Jay Vosburgh indicated he would rather see a
> feature like this added to existing modes rather than creating a
> completely new mode.  Jay's thoughts as well as Neil's input surrounding
> some of the issues with the first implementation pushed us toward a
> design that relied on the queue_mapping rather than skb marks.
> Round-robin and active-backup modes were chosen as the first users of
> this slave selection as they seemed like the most logical choices when
> considering a multi-switch environment.
> 
> Round-robin mode works without any modification, but active-backup does
> require inclusion of the first patch in this series and setting
> the 'all_slaves_active' flag.  This will allow reception of unicast traffic on
> any of the backup interfaces.
> 
> This was tested with IPv4-based filters as well as VLAN-based filters
> with good results.
> 
> More information as well as a configuration example is available in the
> patch to Documentation/networking/bonding.txt.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
