From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v4 00/14] l2tp: Introduce L2TPv3 support
Date: Sat, 03 Apr 2010 15:04:32 -0700 (PDT)
Message-ID: <20100403.150432.206024279.davem@davemloft.net>
References: <20100402161822.11367.70454.stgit@bert.katalix.com>
	<20100403.142522.01040744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60748
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058Ab0DCWEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 18:04:32 -0400
In-Reply-To: <20100403.142522.01040744.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 03 Apr 2010 14:25:22 -0700 (PDT)

> From: James Chapman <jchapman@katalix.com>
> Date: Fri, 02 Apr 2010 17:18:23 +0100
> 
>> This patch series adds L2TPv3 support. It splits the existing pppol2tp
>> driver to separate its L2TP and PPP parts, then adds new L2TPv3
>> functionality. The patches implement a new socket family for L2TPv3 IP
>> encapsulation, expose virtual netdevices for each L2TPv3 ethernet
>> pseudowire and add a netlink interface.
> 
> Ok I'm going to toss this into net-next-2.6, we have time to
> fixup any remaining issues people might discover.

This needed several build fixes which I'll post next.
