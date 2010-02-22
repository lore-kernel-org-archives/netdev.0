From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] af_key: locking change
Date: Mon, 22 Feb 2010 15:46:24 -0800 (PST)
Message-ID: <20100222.154624.57477684.davem@davemloft.net>
References: <20100222175716.900955428@vyatta.com>
	<20100222175742.761539214@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47061
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750953Ab0BVXqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:46:06 -0500
In-Reply-To: <20100222175742.761539214@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 22 Feb 2010 09:57:19 -0800

> Get rid of custom locking that was using wait queue, lock, and atomic
> to basically build a queued mutex.  Use RCU for read side.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
