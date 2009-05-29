From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: dont release skb->dst in veth_xmit()
Date: Fri, 29 May 2009 15:15:38 -0700 (PDT)
Message-ID: <20090529.151538.235706411.davem@davemloft.net>
References: <4A1FAB3C.9090406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47146
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751585AbZE2WPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:15:38 -0400
In-Reply-To: <4A1FAB3C.9090406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 May 2009 11:30:36 +0200

> No need to release skb->dst, its now done by core network.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
