From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: DCB generic netlink interface
Date: Tue, 10 Jun 2008 13:07:26 -0700 (PDT)
Message-ID: <20080610.130726.121879453.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC32905348FD4@orsmsx414.amr.corp.intel.com>
	<20080605.074324.38999631.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753201AbYFJUH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 16:07:27 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Tue, 10 Jun 2008 12:55:16 -0700

> The 802.1Qbb, per-priority pause (flow control), cannot work in a
> software implementation.

Of course, I know that.

> Also, the Rx filtering can't be emulated in software either.  The
> MAC filters on VLAN priority.  I know that can be configured with
> vconfig and set_ingress_map, but the whole point of the technology
> is to have the Rx processing done in the hardware's packet buffers,
> much like RSS filtering.

This is a scare crow, please don't use arguments like that.

Saying that it can't be done at all in software, but then saying
"well, it sort of can be done, but the point is to do it in hardware"
side-steps the very reason I want you to implement a software variant
of the parts that can be done in software.

> This technology really is a hardware-based technology.

This sounds like another way of saying "having a software
implementation of even some of this facility would compromise
the value of our hardware implementation."

That's not the kind of decision making process we use when
deciding how to implement things in the kernel.
