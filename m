From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv6: use round_jiffies
Date: Tue, 22 Jul 2008 14:34:15 -0700 (PDT)
Message-ID: <20080722.143415.79214850.davem@davemloft.net>
References: <20080722212927.937523165@vyatta.com>
	<20080722212951.629007462@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56352
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753632AbYGVVeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:34:15 -0400
In-Reply-To: <20080722212951.629007462@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 22 Jul 2008 14:29:29 -0700

> This timer normally happens once a minute, there is no need to cause an
> early wakeup for it, so align it to next second boundary to safe power.
> It can't be deferred because then it could take too long on cleanup or DoS.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
