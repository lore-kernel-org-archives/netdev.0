From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16529] New: xennet driver crashes when using
 with pseudowire aka l2tpv3
Date: Thu, 26 Aug 2010 13:30:02 -0700 (PDT)
Message-ID: <20100826.133002.179954659.davem@davemloft.net>
References: <1282806640.3469.26.camel@localhost.localdomain>
	<1282809788.2476.59.camel@edumazet-laptop>
	<1282815875.2476.294.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@eu.citrix.com, jeremy@goop.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	chrisw@sous-sol.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jchapman@katalix.com,
	heil@terminal-consulting.de, Xen-devel@lists.xensource.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38919
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753383Ab0HZU3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 16:29:52 -0400
In-Reply-To: <1282815875.2476.294.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Aug 2010 11:44:35 +0200

> [PATCH] l2tp: test for ethernet header in l2tp_eth_dev_recv()
> 
> close https://bugzilla.kernel.org/show_bug.cgi?id=16529
> 
> Before calling dev_forward_skb(), we should make sure skb head contains
> at least an ethernet header, even if length included in upper layer said
> so. Use pskb_may_pull() to make sure this ethernet header is present in
> skb head.
> 
> Reported-by: Thomas Heil <heil@terminal-consulting.de>
> Reported-by: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
