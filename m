From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net/802: add __rcu annotations
Date: Mon, 25 Oct 2010 13:10:47 -0700 (PDT)
Message-ID: <20101025.131047.70206624.davem@davemloft.net>
References: <1287991956.2658.5384.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49975
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757877Ab0JYUKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 16:10:24 -0400
In-Reply-To: <1287991956.2658.5384.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Oct 2010 09:32:36 +0200

> (struct net_device)->garp_port is rcu protected :
> (struct garp_port)->applicants is rcu protected :
> 
> add __rcu annotation and proper rcu primitives.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
