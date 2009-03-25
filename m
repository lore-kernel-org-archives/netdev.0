From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 0/6] s390: qeth fixes for 2.6.30
Date: Wed, 25 Mar 2009 09:25:14 +0100
Message-ID: <49C9EA6A.90808@linux.vnet.ibm.com>
References: <20090325065713.054133000@de.ibm.com> <20090325.000817.183932373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:62548 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbZCYIZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 04:25:16 -0400
In-Reply-To: <20090325.000817.183932373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Any particular reason you wait until right when the
> merge window opens to send me stuff?
> 
> I said on netdev that I wanted to empty my patchwork
> queue then submit the tree to Linus.
> 
> So then you send me more stuff on top of that? :-/
> 
> Please don't wait until the last moment next time.

Sorry, this was by accident. Next time I will send the patches
sooner.

> Applied.
> 
>> Frank Blaschka (2)
>> qeth: add statistics for tx csum
>> qeth: remove EDDP
> 
> Your EDDP was slow because the implementation was incredibly
> sub-optimal.  %90 of the code is doing copies and fiddling
> with SKB internals.

I did not wrote the EDDP code but this was my impression too. Thanks for
confirming my study. Also the filling of the hardware buffers was not
efficient and passing more buffers to the hw was expensive too.



