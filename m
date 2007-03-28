From: David Miller <davem@davemloft.net>
Subject: Re: reverting handle_bridge() change from net-2.6.22
Date: Tue, 27 Mar 2007 19:40:55 -0700 (PDT)
Message-ID: <20070327.194055.41636204.davem@davemloft.net>
References: <20070327.193809.74746967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933535AbXC1Ck4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 22:40:56 -0400
In-Reply-To: <20070327.193809.74746967.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 27 Mar 2007 19:38:09 -0700 (PDT)

> It doesn't build with bridging disabled, and I can't see
> exactly how to work out the 'ret' assignment in the way
> the new code works so I'm reverting.
> 
> Please resubmit a version that builds and works properly
> with bridging enabled and disabled, thanks :-)

In fact I am reverting all 3 patches because the latter
2 have dependencies on the first one, please resubmit all
3 when the build failure is resolved.

Thanks.
