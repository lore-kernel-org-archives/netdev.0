From: Christoph Hellwig <hch@infradead.org>
Subject: Re: pktgen
Date: Fri, 1 Dec 2006 08:22:25 +0000
Message-ID: <20061201082225.GA19683@infradead.org>
References: <b6fcc0a0611292330n42fb1485h59804cc94a332f19@mail.gmail.com> <17774.39482.949953.625608@robur.slu.se> <456F15F7.3000700@candelatech.com> <20061130.201423.118625277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, Robert.Olsson@data.slu.se,
	adobriyan@gmail.com, pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:23994 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S967534AbWLAIWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 03:22:34 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061130.201423.118625277.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 30, 2006 at 08:14:23PM -0800, David Miller wrote:
> Agreed.
> 
> Robert, please fix this by using a completion so that we can
> wait for the threads to start up, something like this:

No, that's wrong aswell :)  Please use the kthread_ API that takes
care of all this.  kernel_thread is going away mid-term, so you'd
have to do this work anyway.

