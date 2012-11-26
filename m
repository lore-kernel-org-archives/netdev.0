From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ptp: reduce stack usage when measuring
 the system time offset
Date: Mon, 26 Nov 2012 17:23:36 -0500 (EST)
Message-ID: <20121126.172336.2075146228529710034.davem@davemloft.net>
References: <20121102020631.GI16883@yliu-dev.sh.intel.com>
	<1146e32bcb835ebf394bab91db3161600ab5213a.1353929829.git.richardcochran@gmail.com>
	<6151dfc7e5bb80d73563502a2a14c9f2aad8bdb0.1353929830.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757277Ab2KZWXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:23:40 -0500
In-Reply-To: <6151dfc7e5bb80d73563502a2a14c9f2aad8bdb0.1353929830.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 26 Nov 2012 12:44:35 +0100

> This patch removes the large buffer from the stack of the system
> offset ioctl and replaces it with a kmalloced buffer.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied.
