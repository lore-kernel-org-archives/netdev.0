From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: reorder fields in struct neighbour
Date: Fri, 01 Oct 2010 00:37:08 -0700 (PDT)
Message-ID: <20101001.003708.133896102.davem@davemloft.net>
References: <1285860989.2615.650.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38997
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752801Ab0JAHgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 03:36:47 -0400
In-Reply-To: <1285860989.2615.650.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Sep 2010 17:36:29 +0200

> On 64bit arches, there are two 32bit holes that we can remove.
> 
> sizeof(struct neighbour) shrinks from 0xf8 to 0xf0 bytes
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
