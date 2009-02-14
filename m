From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/6] igb: misc cleanup to combine one if
 statement and set last_rx
Date: Fri, 13 Feb 2009 21:43:34 -0800 (PST)
Message-ID: <20090213.214334.255485732.davem@davemloft.net>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
	<20090213041804.3848.73723.stgit@lost.foo-projects.org>
	<1234531403.3110.3.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, gospo@redhat.com, alexander.h.duyck@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47950
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbZBNFnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 00:43:40 -0500
In-Reply-To: <1234531403.3110.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 13 Feb 2009 13:23:23 +0000

> On Thu, 2009-02-12 at 20:18 -0800, Jeff Kirsher wrote:
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > 
> > This patch combines a pair of if statements into one and adds a line to
> > update netdev->last_rx.
> [...]
> 
> You shouldn't need to update last_rx any more:
> 
> commit 6cf3f41e6c08bca6641a695449791c38a25f35ff
> Author: Jay Vosburgh <fubar@us.ibm.com>
> Date:   Mon Nov 3 18:16:50 2008 -0800
> 
>     bonding, net: Move last_rx update into bonding recv logic

Right.
