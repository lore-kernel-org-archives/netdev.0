From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Freeing alive inet6 address
Date: Tue, 11 Sep 2007 02:08:18 -0700 (PDT)
Message-ID: <20070911.020818.71091588.davem@davemloft.net>
References: <20070907102118.GA27780@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@openvz.org, xemul@openvz.org, dev@openvz.org,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, devel@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:41334
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933195AbXIKJIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 05:08:52 -0400
In-Reply-To: <20070907102118.GA27780@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 7 Sep 2007 14:21:18 +0400

> From: Denis V. Lunev <den@openvz.org>
> 
> addrconf_dad_failure calls addrconf_dad_stop which takes referenced address
> and drops the count. So, in6_ifa_put perrformed at out: is extra. This
> results in message: "Freeing alive inet6 address" and not released dst entries.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Signed-off-by: Alexey Dobriyan <adobriyan@openvz.org>

I've seen this bug myself just a week before heading to
Europe for conferences and intended to look into it.

Thanks a lot for fixing this, patch applied.
