From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 14:55:34 -0700 (PDT)
Message-ID: <20070612.145534.128867899.davem@davemloft.net>
References: <466F0D78.7090404@candelatech.com>
	<20070612.142658.45082832.davem@davemloft.net>
	<20070612214753.GB27363@metaxa.reflex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, jeff@garzik.org, netdev@vger.kernel.org,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: lunz@falooley.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58465
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753681AbXFLVzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 17:55:18 -0400
In-Reply-To: <20070612214753.GB27363@metaxa.reflex>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Lunz <lunz@falooley.org>
Date: Tue, 12 Jun 2007 17:47:53 -0400

> Are you aware of any hardware designs that allow other ways to map
> packets onto rx queues?  I can think of several scenarios where it could
> be advantageous to map packets by IP 3- or 5-tuple to get cpu locality
> all the way up the stack on a flow-by-flow basis. But doing this would
> require some way to request this mapping from the hardware.

These chips allow this too, Microsoft defined a standard for
RX queue interrupt hashing by flow so everyone puts it, or
something like it, in hardware.

> In the extreme case it would be cool if it were possible to push a
> bpf-like classifier down into the hardware to allow arbitrary kinds of
> flow distribution.

Maybe not a fully bpf, but many chips allow something close.
