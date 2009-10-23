From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ifb: should not use __dev_get_by_index() without locks
Date: Thu, 22 Oct 2009 21:54:47 -0700 (PDT)
Message-ID: <20091022.215447.202850721.davem@davemloft.net>
References: <4ADD3B5A.1080905@gmail.com>
	<20091019.212855.179405364.davem@davemloft.net>
	<4ADDAEA6.2040903@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54813
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750864AbZJWEyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 00:54:24 -0400
In-Reply-To: <4ADDAEA6.2040903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Oct 2009 14:35:50 +0200

> [PATCH] ifb: should not use __dev_get_by_index() without locks
> 
> At this point (ri_tasklet()), RTNL or dev_base_lock are not held,
> we must use dev_get_by_index() instead of __dev_get_by_index()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
