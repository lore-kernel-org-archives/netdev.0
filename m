From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] Consolidate IP fragment management
Date: Mon, 15 Oct 2007 02:42:48 -0700 (PDT)
Message-ID: <20071015.024248.61355576.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756805AbXJOJmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:42:43 -0400
In-Reply-To: <470F6EAE.60308@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 16:55:10 +0400

> Patrick recently pointed out, that there are three places that 
> perform IP fragments management. In ipv4, ipv6 and in ip6 
> conntracks. Looks like these places can be a bit consolidated.
> 
> The proposal is to create a common structure inet_frag_queue to 
> put common fields like list heads, refcounts etc in, and include
> it into the specific fragment queues. Then such objects like 
> hash tables, lists, locks etc are moved to common place (struct 
> inet_frags). At the end common code is moved to the 
> net/ipv4/inet_fragment.c.
> 
> The inet_ prefix in file names, data structures and functions, and
> the code place (net/ipv4) was proposed by Alexey, but the exact
> names were selectd by me, so maybe there can be a better ones.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thank you for doing this work, I applied it all.

I had to decide whether to apply Herbert's recent patches
first or your's, because either way there would be some
conflicts to resolve.

I handled it the best I could, but it seems OK from here.
