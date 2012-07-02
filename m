From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 02 Jul 2012 01:34:45 -0700 (PDT)
Message-ID: <20120702.013445.1273332212099485403.davem@davemloft.net>
References: <4FF042B5.1000303@mellanox.com>
	<20120701.144252.792146486861614931.davem@davemloft.net>
	<4FF153F0.8080707@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab2GBIes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 04:34:48 -0400
In-Reply-To: <4FF153F0.8080707@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 2 Jul 2012 10:55:28 +0300

> On 7/2/2012 12:42 AM, David Miller wrote:
>> [...] Module parameters stink because every driver is going to provide
>> the knob differently, with a different name, and different
>> semantics. This creates a terrible user experience, and I will not
>> allow it.
> 
> OK, so if looking on what we are left with on the table, seems that
> sysfs entry on the mlx4_core
> level (as we do for the port link type {IB, Eth} or IB port MTU) could
> be fine here, Roland, agree?

No way.

You have to create a real interface, that other vendors with similar
chips can consistently use.
