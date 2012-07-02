From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 2 Jul 2012 10:55:28 +0300
Message-ID: <4FF153F0.8080707@mellanox.com>
References: <1341135823-29039-7-git-send-email-ogerlitz@mellanox.com> <20120701.033055.489908836962064737.davem@davemloft.net> <4FF042B5.1000303@mellanox.com> <20120701.144252.792146486861614931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, <hadarh@mellanox.co.il>
To: David Miller <davem@davemloft.net>, <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:35470 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751362Ab2GBHzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 03:55:43 -0400
In-Reply-To: <20120701.144252.792146486861614931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/2012 12:42 AM, David Miller wrote:
> [...] Module parameters stink because every driver is going to provide 
> the knob differently, with a different name, and different semantics. 
> This creates a terrible user experience, and I will not allow it. 

OK, so if looking on what we are left with on the table, seems that 
sysfs entry on the mlx4_core
level (as we do for the port link type {IB, Eth} or IB port MTU) could 
be fine here, Roland, agree?

Or.

We're talking on the /sys/bus/pci/devices entry for the card, e.g for a 
card sitting
in 06:00.0 this new entry will be under /sys/bus/pci/devices/0000:06:00.0/
