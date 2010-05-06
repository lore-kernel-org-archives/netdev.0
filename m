From: David Miller <davem@davemloft.net>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Thu, 06 May 2010 00:44:57 -0700 (PDT)
Message-ID: <20100506.004457.71584133.davem@davemloft.net>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
	<1273111530.21962.2753.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48817
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181Ab0EFHou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:44:50 -0400
In-Reply-To: <1273111530.21962.2753.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 05 May 2010 21:05:30 -0500

> On Wed, 2010-05-05 at 04:11 -0400, Amerigo Wang wrote:
>> V5:
>> Fix coding style problems pointed by David.
> 
> Aside from my concern about the policy of disabling netpoll on
> bridges/bonds with only partial netpoll support, I don't have any
> remaining issues with this. But I'll leave it to other folks to ack the
> underlying driver bits for this series.

Yes the partial support handling is a thorny issue.

But this patch set makes things better than they were before, because
support over such devices didn't work at all previously.

So I'll toss these patches into net-next-2.6, thanks everyone!
