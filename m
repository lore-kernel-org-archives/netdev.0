From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: RCU conversion
Date: Tue, 15 Jun 2010 14:25:06 -0700 (PDT)
Message-ID: <20100615.142506.02275206.davem@davemloft.net>
References: <1276626194.2541.186.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758430Ab0FOVYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 17:24:55 -0400
In-Reply-To: <1276626194.2541.186.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Jun 2010 20:23:14 +0200

> inetpeer currently uses an AVL tree protected by an rwlock.
> 
> It's possible to make most lookups use RCU
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, nice work Eric.
