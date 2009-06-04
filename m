From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Wed, 03 Jun 2009 21:53:14 -0700 (PDT)
Message-ID: <20090603.215314.96383042.davem@davemloft.net>
References: <4A2620FD.8030708@trash.net>
	<20090603074049.GA5254@ff.dom.local>
	<4A262BE7.4090807@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, vexwek@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, devik@cdi.cz, dada1@cosmosbay.com,
	hazard@francoudi.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37613
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbZFDExN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 00:53:13 -0400
In-Reply-To: <4A262BE7.4090807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 03 Jun 2009 09:53:11 +0200

> Jarek Poplawski wrote:
>> On Wed, Jun 03, 2009 at 09:06:37AM +0200, Patrick McHardy wrote:
>>> Mid-term we really need to move to 64 bit values and ns resolution,
>>> otherwise this problem is just going to reappear as soon as someone
>>> tries 10gbit. Not sure what the best short term fix is, I feel a bit
>>> uneasy about changing the current factors given how close this brings
>>> us towards overflowing.
>> I completely agree it's on the verge of overflow, and actually would
>> overflow for some insanely low (for today's standards) rates. So I
>> treat it's as a temporary solution, until people start asking about
>> more than 1 or 2Gbit. And of course we will have to move to 64 bit
>> anyway. Or we can do it now...
> 
> That (now) would certainly be the best solution, but its a non-trivial
> task since all the ABIs use 32 bit values.

We could pass in a new attribute which provides the upper-32bits
of the value.  I'm not sure if that works in this case but it's
an idea.

