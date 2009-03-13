From: David Miller <davem@davemloft.net>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
 - twice
Date: Fri, 13 Mar 2009 16:12:17 -0700 (PDT)
Message-ID: <20090313.161217.52045656.davem@davemloft.net>
References: <49AA8B4F.8090405@krogh.cc>
	<9712.1236279072@death.nxdomain.ibm.com>
	<49B581D3.6060807@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@redhat.com, aowi@novozymes.com
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46450
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751998AbZCMXMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 19:12:31 -0400
In-Reply-To: <49B581D3.6060807@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Mon, 09 Mar 2009 21:53:39 +0100

> Jay Vosburgh wrote:
> > 	However, I did find another bug I introduced during the "mii
> > refactor" patch that you mentioned as being the original source of the
> > problem.  That bug will cause 802.3ad to not notice speed changes.
> > 	Could you test the patch below on your 2.6.68.7 and/or 2.6.27.19
> > and see if it resolves your problem (without the forcedeth patch)?
> 
> There was something missing from the header to make it compile.. I found that in a later version. Patch below fixed the problem (without the forcedeth patch).

Jay please resend this with proper signoffs etc. if you want
me to apply it.
