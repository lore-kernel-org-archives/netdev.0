From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: veth: Zero timestamp in xmit path.
Date: Tue, 21 Jul 2009 12:51:55 -0700 (PDT)
Message-ID: <20090721.125155.168882282.davem@davemloft.net>
References: <4A661B2F.7000608@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753107AbZGUTvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 15:51:50 -0400
In-Reply-To: <4A661B2F.7000608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 21 Jul 2009 12:46:55 -0700

> This patch zero's the timestamp before handing the packet to
> the peer interface.  This lets the peer recalculate the rx timestamp
> if it cares about timestamps.
> 
> The patch is against net-next, compile tested there.  Similar patch
> was
> functionally tested against 2.6.31-rc3.
> 
> 
> Signed-Off-By:  Ben Greear<greearb@candelatech.com>

Oh, where to begin... sigh...

The "off" and "by" in "Signed-off-by" is not capitalized.

There should not be two spaces after the Signed-off-by colon, there
should be only one.

There should be a space between your name and your <> enclosed email
address.

> @@ -171,6 +171,7 @@ static int veth_xmit(struct sk_buff *skb, struct
> net_device *dev)

Your email client corrupted the patch by splitting up this line.

This is all just being sloppy, and it shows a lack of care put
into your submission.

Nevertheless I'm a sucker and I fixed this all up and applied your
patch.
