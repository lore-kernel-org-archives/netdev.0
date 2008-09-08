From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Reduce structures when XFRM=n
Date: Mon, 08 Sep 2008 16:22:07 -0700 (PDT)
Message-ID: <20080908.162207.138343845.davem@davemloft.net>
References: <20080907194449.GA3764@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754319AbYIHXWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 19:22:13 -0400
In-Reply-To: <20080907194449.GA3764@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 7 Sep 2008 23:44:49 +0400

> #ifdef out
> * struct sk_buff::sp		(pointer)
> * struct dst_entry::xfrm	(pointer)
> * struct sock::sk_policy	(2 pointers)
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Please do not plaster XFRM ifdefs all over code code like net/ipv4/icmp.c
and friends, instead make the xfrm*() interfaces inline nops when XFRM
is turned off.
