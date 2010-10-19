From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: avoid a dev refcount in
 ip_mc_find_dev()
Date: Tue, 19 Oct 2010 03:51:19 -0700 (PDT)
Message-ID: <20101019.035119.183043744.davem@davemloft.net>
References: <1287484758.2676.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33741
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758160Ab0JSKu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 06:50:57 -0400
In-Reply-To: <1287484758.2676.73.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Oct 2010 12:39:18 +0200

> We hold RTNL in ip_mc_find_dev(), no need to touch device refcount.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
