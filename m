From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.4] bridge netfilter deadlock
Date: Wed, 01 Nov 2006 17:29:52 -0800 (PST)
Message-ID: <20061101.172952.101869474.davem@davemloft.net>
References: <20061101114550.459eead0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59610
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751482AbWKBB3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 20:29:47 -0500
To: shemminger@osdl.org
In-Reply-To: <20061101114550.459eead0@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 1 Nov 2006 11:45:50 -0800

> A deadlock was found in bridge netfilter code (2.4 only), when a device is removed.
> The device removal path causes a BPDU to be generated and ends up
> self deadlocking on the BR lock.
> 
> Simple fix would be to avoid generating config bpdu's
> immediately when becoming root bridge, and just let the first hello
> timer tick do that.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, I'll push this to Willy.

Thanks Stephen.
