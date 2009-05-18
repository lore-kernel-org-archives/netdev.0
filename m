From: David Miller <davem@davemloft.net>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 14:52:33 -0700 (PDT)
Message-ID: <20090518.145233.212710505.davem@davemloft.net>
References: <20090516141430.GB3013@ami.dom.local>
	<4A118F98.60101@cosmosbay.com>
	<20090518172349.GA2755@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, vexwek@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, devik@cdi.cz
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753045AbZERVwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 17:52:35 -0400
In-Reply-To: <20090518172349.GA2755@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 May 2009 19:23:49 +0200

> On Mon, May 18, 2009 at 06:40:56PM +0200, Eric Dumazet wrote:
>> With a typical estimator "1sec 8sec", ewma_log value is 3
>> 
>> At gigabit speeds, we are very close to overflow yes, since
>> we only have 27 bits available, so 134217728 bytes per second
>> or 1073741824 bits per second.
>> 
>> So formula :
>> e->avbps += ((long)rate - (long)e->avbps) >> e->ewma_log;
>> is going to overflow.
>> 
>> One way to avoid the overflow would be to use a smaller estimator, like "500ms 4sec" 
>> 
>> Or use a 64bits rate & avbps, this is needed fo 10Gb speeds I suppose...
> 
> Yes, I considered this too, but because of an overhead I decided to
> fix as designed (according to the comment) for now. But probably you
> are right, and we should go further, so I'm OK with your patch.

I like this patch too, Eric can you submit this formally with
proper signoffs etc.?

Thanks!
