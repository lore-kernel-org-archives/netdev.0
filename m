From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netlabel: remove dev_put() calls
Date: Thu, 05 Nov 2009 21:08:15 -0800 (PST)
Message-ID: <20091105.210815.251131968.davem@davemloft.net>
References: <4AF1DE29.7010408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753185AbZKFFHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:49 -0500
In-Reply-To: <4AF1DE29.7010408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 21:03:53 +0100

> Use dev_get_by_name_rcu() to avoid dev_put() calls,
> in sections already inside a rcu_read_lock()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
