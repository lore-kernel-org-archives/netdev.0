From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 16:53:56 -0700 (PDT)
Message-ID: <20070606.165356.102125635.davem@davemloft.net>
References: <1181168020.4064.46.camel@localhost>
	<20070606.153530.48530367.davem@davemloft.net>
	<1181172766.4064.83.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60868
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763926AbXFFXxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:53:40 -0400
In-Reply-To: <1181172766.4064.83.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 06 Jun 2007 19:32:46 -0400

> So use a different scheduler. Dont use strict prio. Strict prio will
> guarantee starvation of low prio packets as long as there are high prio
> packets. Thats the intent.

Ok, point taken.

There are of course other uses for multiple TX queues, and in
particular my finer-grained locking example.

I'm still amazed the TX locking issue wasn't clear to you,
too nervous about tonight's game? :)
