From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Avoid rtnl_unlock without rtnl_lock
Date: Sat, 13 Mar 2010 12:24:26 -0800 (PST)
Message-ID: <20100313.122426.98704617.davem@davemloft.net>
References: <4B9ACA33.5060104@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932971Ab0CMUYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 15:24:05 -0500
In-Reply-To: <4B9ACA33.5060104@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Sat, 13 Mar 2010 08:11:47 +0900

> Make sure we always call rtnl_lock before going down the
> error path in sky2_resume, which unlocks the rtnl lock.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

Applied, thanks Mike.
