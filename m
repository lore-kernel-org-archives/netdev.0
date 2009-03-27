From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix "error: implicit declaration of function
 'page_address'"
Date: Fri, 27 Mar 2009 15:58:24 -0700 (PDT)
Message-ID: <20090327.155824.63022608.davem@davemloft.net>
References: <20090327155327.GA14867@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751434AbZC0W6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 18:58:36 -0400
In-Reply-To: <20090327155327.GA14867@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 27 Mar 2009 18:53:27 +0300

> As seen on mips:
> 
> In file included from include/net/sock.h:50,
>                  from security/selinux/avc.c:25:
> include/linux/netdevice.h: In function 'skb_gro_mac_header':
> include/linux/netdevice.h:1132: error: implicit declaration of function 'page_address'
> include/linux/netdevice.h:1133: warning: pointer/integer type mismatch in conditional expression
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Yep, I just applied a similar fix from Dmitri Vorobiev.

Thanks!
