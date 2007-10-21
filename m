From: David Miller <davem@davemloft.net>
Subject: Re: net: alignment problem in icmp code
Date: Sat, 20 Oct 2007 22:12:57 -0700 (PDT)
Message-ID: <20071020.221257.78359286.davem@davemloft.net>
References: <20071020233540.43d2f103@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drzeus@drzeus.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750922AbXJUFMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 01:12:45 -0400
In-Reply-To: <20071020233540.43d2f103@poseidon.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ossman <drzeus@drzeus.cx>
Date: Sat, 20 Oct 2007 23:35:40 +0200

> Structure assignment have to be aligned just like any assignment, and the skb could point to anything. So take the safe route and use a memcpy().
> 
> Signed-off-by: Pierre Ossman <drzeus@drzeus.cx>

Unfortunately this doesn't work, GCC can inline the memcpy just like
the assignment.

I tried to use a similar trick in the net/xfrm/xfrm_user.c code
but in the end it doesn't work at all.
