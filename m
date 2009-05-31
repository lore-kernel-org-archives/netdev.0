From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unset IFF_XMIT_DST_RELEASE for qeth and ipoib
Date: Sat, 30 May 2009 23:04:54 -0700 (PDT)
Message-ID: <20090530.230454.01445570.davem@davemloft.net>
References: <4A20F628.60002@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58630
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbZEaGEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 02:04:54 -0400
In-Reply-To: <4A20F628.60002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 May 2009 11:02:32 +0200

> Last two drivers that need skb->dst in their start_xmit() function
> 
> Tell dev_hard_start_xmit() to no release it by unsetting  IFF_XMIT_DST_RELEASE
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
