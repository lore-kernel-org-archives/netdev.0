From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] 3c59x: Remove incorrect locking; correct
 documented lock hierarchy
Date: Wed, 01 Sep 2010 18:02:10 -0700 (PDT)
Message-ID: <20100901.180210.129766746.davem@davemloft.net>
References: <1283378907.5323.287.camel@localhost>
	<20100901.173736.190380817.davem@davemloft.net>
	<1283388178.5323.300.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38038
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752357Ab0IBBBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 21:01:53 -0400
In-Reply-To: <1283388178.5323.300.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 02 Sep 2010 01:42:58 +0100

> On Wed, 2010-09-01 at 17:37 -0700, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Wed, 01 Sep 2010 23:08:27 +0100
>> 
>> > I think this is safe after all because ethtool and MII ioctls are all
>> > serialised by the RTNL.
>> 
>> Well since you said that there was a regression that you're unable
>> to reproduce, I was trying to find a probably cause for it :-)
>> 
>> I think you should work to resolve that report, and resend this
>> locking patch once that is sorted out.
> 
> That regression seems to due to my *earlier* changes to locking.  This
> new patch fixes a different regression I found while trying to reproduce
> that, and it has not been applied in Debian yet.  Sorry for the
> ambiguous wording.

Gotcha, patch applied to net-2.6, thanks.
