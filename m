From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8 net-2.6.26] [NETNS]: namespace refcounting cleanup
Date: Wed, 16 Apr 2008 02:07:54 -0700 (PDT)
Message-ID: <20080416.020754.130255465.davem@davemloft.net>
References: <1208262959.21529.32.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34013
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754702AbYDPJHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 05:07:53 -0400
In-Reply-To: <1208262959.21529.32.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 15 Apr 2008 16:35:59 +0400

> Network namespace has two referrence counters:
> - count
> - use_count.
> The namespace is scheduled to destruction automatically when the count
> becomes 0.
> 
> There are several SLAB objects with a pointer to a namespace on them.
> These objects are cleaned up during namespace stop. Some of them
> increment use_count, some don't. This set fixes this discrepancy,
> i.e. now all such objects increment the use_count.
> 
> Though, the use_count itself is used in a very debug manner and checked
> only during namespace stop. So, I have placed it under
> NETNS_REFCNT_DEBUG definition exactly like this is done for socket
> refcounting code to remove extra atomic from any possible fast paths.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

This is a notification that the Linux NETDEV Patch Robot has used all
automated tools known to man to validate your patches, and has decided
to apply then to the net-2.6.26 GIT tree.

*beep* *beep*

You may continue hacking.

*beep* *beep*

Have a pleasant day.
