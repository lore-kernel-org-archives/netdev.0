From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 patch 2/2][NETNS] Fix reassembly timer to use the
 right namespace
Date: Fri, 02 May 2008 17:02:37 -0700 (PDT)
Message-ID: <20080502.170237.24392605.davem@davemloft.net>
References: <20080430213113.410541118@localhost.localdomain>
	<20080430213322.234776390@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48616
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758525AbYECACh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 20:02:37 -0400
In-Reply-To: <20080430213322.234776390@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 30 Apr 2008 23:31:15 +0200

> This trivial fix retrieves the network namespace from frag queue
> and use it to get the network device in the right namespace.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

The one area where ipv4 and ipv6 code didn't get fully
considated, and voila!  ipv4 got it right and ipv6 had
the bug :-)

Patch applied, thanks!
