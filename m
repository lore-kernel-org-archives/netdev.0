From: David Miller <davem@davemloft.net>
Subject: Re: pktgen
Date: Fri, 01 Dec 2006 15:17:37 -0800 (PST)
Message-ID: <20061201.151737.124084161.davem@davemloft.net>
References: <456F15F7.3000700@candelatech.com>
	<20061130.201423.118625277.davem@davemloft.net>
	<20061201082225.GA19683@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, Robert.Olsson@data.slu.se,
	adobriyan@gmail.com, pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:27778
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1162219AbWLAXRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 18:17:31 -0500
To: hch@infradead.org
In-Reply-To: <20061201082225.GA19683@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 1 Dec 2006 08:22:25 +0000

> On Thu, Nov 30, 2006 at 08:14:23PM -0800, David Miller wrote:
> > Agreed.
> > 
> > Robert, please fix this by using a completion so that we can
> > wait for the threads to start up, something like this:
> 
> No, that's wrong aswell :)  Please use the kthread_ API that takes
> care of all this.  kernel_thread is going away mid-term, so you'd
> have to do this work anyway.

I was going to suggest this Christophe, but I wanted a change small
and easy enough to verify in order to merge the fix into the -stable
branch.  Converting the thing over to kthread would make the change
more risky in such a context.

