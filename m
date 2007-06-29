From: David Miller <davem@davemloft.net>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 14:31:02 -0700 (PDT)
Message-ID: <20070629.143102.88475921.davem@davemloft.net>
References: <1183117415.5156.61.camel@localhost>
	<4684F41B.9080309@trash.net>
	<1183121670.5188.16.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55219
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbXF2Van (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 17:30:43 -0400
In-Reply-To: <1183121670.5188.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This conversation begins to go into a pointless direction already, as
I feared it would.

Nobody is going to configure bridges, classification, tc, and all of
this other crap just for a simple virtualized guest networking device.

It's a confined and well defined case that doesn't need any of that.
You've got to be fucking kidding me if you think I'm going to go
through the bridging code and all of that layering instead of my
hash demux on transmit which is 4 or 5 lines of C code at best.

Such a suggestion is beyond stupid.

Maybe for the control node switch, yes, but not for the guest network
devices.
