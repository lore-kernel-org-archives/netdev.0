From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reduce structures when XFRM=n
Date: Tue, 28 Oct 2008 13:24:20 -0700 (PDT)
Message-ID: <20081028.132420.14839895.davem@davemloft.net>
References: <20081028124622.GA9347@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752827AbYJ1UYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 16:24:43 -0400
In-Reply-To: <20081028124622.GA9347@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 28 Oct 2008 15:46:22 +0300

> ifdef out
> * struct sk_buff::sp		(pointer)
> * struct dst_entry::xfrm	(pointer)
> * struct sock::sk_policy	(2 pointers)
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Fair enough, applied to net-next-2.6, thanks!
