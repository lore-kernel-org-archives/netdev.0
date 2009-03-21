From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: reorder struct inet6_ifaddr to remove padding on
 64 bit builds
Date: Sat, 21 Mar 2009 13:29:17 -0700 (PDT)
Message-ID: <20090321.132917.32958808.davem@davemloft.net>
References: <1237476760.3266.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: richard@rsk.demon.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753625AbZCUU3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:29:30 -0400
In-Reply-To: <1237476760.3266.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Kennedy <richard@rsk.demon.co.uk>
Date: Thu, 19 Mar 2009 15:32:40 +0000

> reorder struct inet6_ifaddr to remove padding on 64 bit builds
>     
> remove 8 bytes of padding so inet6_ifaddr becomes 192 bytes & fits into
> a smaller slab.
>     
> Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>

Applied, thanks.
