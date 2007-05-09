From: David Miller <davem@davemloft.net>
Subject: Re: linkwatch bustage in git-net
Date: Wed, 09 May 2007 14:39:25 -0700 (PDT)
Message-ID: <20070509.143925.25157363.davem@davemloft.net>
References: <20070509071614.GA2138@gondor.apana.org.au>
	<20070509.001814.116354599.davem@davemloft.net>
	<20070509141103.9de0f654.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752367AbXEIVjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 17:39:25 -0400
In-Reply-To: <20070509141103.9de0f654.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 9 May 2007 14:11:03 -0700

> On Wed, 09 May 2007 00:18:14 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > Thanks for working this out, applied and pushed to net-2.6.git
> 
> I'm all confused.  I just pulled your tree and I see in the log
> 
> 
> 	commit 4cba637dbb9a13706494a1c85174c8e736914010
> 	Author: Herbert Xu <herbert@gondor.apana.org.au>
> 	Date:   Wed May 9 00:17:30 2007 -0700
> 
> 	    [NET] link_watch: Always schedule urgent events
>     
> 
> and
> 
> 
> 	commit fe47cdba83b3041e4ac1aa1418431020a4afe1e0
> 	Author: Herbert Xu <herbert@gondor.apana.org.au>
> 	Date:   Tue May 8 23:22:43 2007 -0700
> 
> 	    [NET] link_watch: Eliminate potential delay on wrap-around
> 
> 
> but in the actual diff and in the checked-out tree I see no sign of the
> earlier patch (fe47cdba83b3041e4ac1aa1418431020a4afe1e0).  I have the old
> code:
> 
>         /* If we wrap around we'll delay it by at most HZ. */
>         if (delay > HZ)
>                 delay = 0;
> 
> 
> where'd it go?

Look at the two individual changes, Herbert implemented the
delay calculations different in the second changeset.  So
the code is much different there now.
