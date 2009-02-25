From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Wed, 25 Feb 2009 04:01:30 -0800 (PST)
Message-ID: <20090225.040130.169376412.davem@davemloft.net>
References: <20090209102134.GA8492@gondor.apana.org.au>
	<20090224.234840.93952093.davem@davemloft.net>
	<20090225115419.GA16150@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, shemminger@vyatta.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757532AbZBYMBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 07:01:49 -0500
In-Reply-To: <20090225115419.GA16150@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 25 Feb 2009 06:54:19 -0500

> I had actually started down this road for awhile, and liked it for
> its low maintenence overhead (as you mentioned, less to annotate),
> but I balked at it after a bit, mostly for its increased ambiguity.
> By catching the drop where the packet is freed, we lose information
> about the exact point at which we decided to drop it.  As such,
> users of said dumped table loose (or potentially lose) the ability
> to correlate the saved stack pointer with an exact point in the code
> where a corresponding statistic was incremented, as well as the
> correlation to a specific point in the code (they just get the
> calling function program counter rather than file, funciton and line
> number).

Userland tools can extract this information from a non-stripped
kernel image file, given just a kernel PC value.

And you need the same thing to extract the same information
if you used tracepoints.
