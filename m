From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: More verbose message for too-many-orphans.
Date: Tue, 10 Aug 2010 01:48:01 -0700 (PDT)
Message-ID: <20100810.014801.212696050.davem@davemloft.net>
References: <1281380402-14608-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50073
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754407Ab0HJIrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:47:41 -0400
In-Reply-To: <1281380402-14608-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon,  9 Aug 2010 12:00:02 -0700

> The original message doesn't give much clue as to what
> is actually going wrong or how to fix it.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Dumping a bunch of values obtainable via sysctl is pointless.

The only non-sysctl value you're dumping is 'orphans' and based upon
the sysctl values you can determine whether it made the check inside
of tcp_too_many_orphans() trigger, and in what way.

I'm not applying this, sorry.
