From: David Miller <davem@davemloft.net>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Fri, 20 Jul 2007 22:33:52 -0700 (PDT)
Message-ID: <20070720.223352.71090112.davem@davemloft.net>
References: <469F38BE.4030401@trash.net>
	<20070720.194743.71090882.davem@davemloft.net>
	<46A17FA2.8010906@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, arekm@maven.pl,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752817AbXGUFdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 01:33:53 -0400
In-Reply-To: <46A17FA2.8010906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 21 Jul 2007 05:38:10 +0200

> Yes, some constant limit definitely makes sense. The Tx batching
> patches motivated me to work through struct net_device with pahole
> and I have some patches that rearrange it to save about 64 bytes and
> move some members from very unfortunate positions to better ones,
> but they still leave two 32 byte holes on SMP (with 64 byte
> cachelines). Plugging one of these with a statically sized subqueue
> array would be perfect since one of the holes is within the Tx
> cachelines anyway (at least for now, until we add subqueue locks ..).

This sounds great.

> Its 2.6.24 material though, and I very much hope they will clash
> with Stephen's plans to introduce struct net_device_ops.

Also see the napi_struct stuff I just posted as well.
