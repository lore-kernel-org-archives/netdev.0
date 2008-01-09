From: David Miller <davem@davemloft.net>
Subject: Re: SACK scoreboard
Date: Tue, 08 Jan 2008 22:35:37 -0800 (PST)
Message-ID: <20080108.223537.03265671.davem@davemloft.net>
References: <4783AA29.3080406@psc.edu>
	<20080108.144456.173014334.davem@davemloft.net>
	<aa7d2c6d0801081734t363768ffi31adb3bd26e639c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, quetchen@caltech.edu
To: lachlan.andrew@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60080
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750920AbYAIGfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:35:38 -0500
In-Reply-To: <aa7d2c6d0801081734t363768ffi31adb3bd26e639c7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Date: Tue, 8 Jan 2008 17:34:03 -0800

> John also suggested freeing the packets as a lower priority task, just
> doing it after they're acknowledged.
> 
> When the ACK finally comes, you could do something like moving John's
> entire list of packets to a "to be freed" list, and free a few every
> time (say) another ACK comes in.

You could, but this requires extra state and the operations to
properly queue such items to the deferred task and wake it up.

And none of this would be necessary if we could make SACK
indications hard.
