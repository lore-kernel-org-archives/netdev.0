From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: round off STP perodic timers
Date: Thu, 31 May 2007 01:21:52 -0700 (PDT)
Message-ID: <20070531.012152.11957542.davem@davemloft.net>
References: <20070519224605.GG14235@galon.ev-en.org>
	<20070530121252.1248f506@freepuppy>
	<20070530121422.0cdd90eb@freepuppy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, netdev@vger.kernel.org, power@bughost.org,
	bridge@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752884AbXEaIVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 04:21:39 -0400
In-Reply-To: <20070530121422.0cdd90eb@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 30 May 2007 12:14:22 -0700

> Peroidic STP timers don't have to be exact.
> The hold timer runs at 1HZ, and the hello timer normally runs
> at 2HZ; save power by aligning it them to next second.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
