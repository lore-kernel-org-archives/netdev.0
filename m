From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] anycast: Some RCU conversions
Date: Mon, 07 Jun 2010 22:57:09 -0700 (PDT)
Message-ID: <20100607.225709.67896114.davem@davemloft.net>
References: <1275946933.2775.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751571Ab0FHF47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 01:56:59 -0400
In-Reply-To: <1275946933.2775.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Jun 2010 23:42:13 +0200

> - dev_get_by_flags() changed to dev_get_by_flags_rcu()
> 
> - ipv6_sock_ac_join() dont touch dev & idev refcounts
> - ipv6_sock_ac_drop() dont touch dev & idev refcounts
> - ipv6_sock_ac_close() dont touch dev & idev refcounts
> - ipv6_dev_ac_dec() dount touch idev refcount
> - ipv6_chk_acast_addr() dont touch idev refcount
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Looks great, applied, thanks Eric!
