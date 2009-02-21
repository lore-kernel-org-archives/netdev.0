From: David Miller <davem@davemloft.net>
Subject: Re: [BUG PATCH NET-NEXT-2.6] kernel panic in dev_hard_start_xmit:
 remove faulty software TX time stamping
Date: Sat, 21 Feb 2009 02:42:40 -0800 (PST)
Message-ID: <20090221.024240.160751163.davem@davemloft.net>
References: <1235208488.22598.40.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, emil.s.tantilov@intel.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56063
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750801AbZBUKm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 05:42:59 -0500
In-Reply-To: <1235208488.22598.40.camel@pohly-MOBL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Sat, 21 Feb 2009 10:28:08 +0100

> The current implementation of the TX software time stamping fallback is
> faulty because it accesses the skb after ndo_start_xmit() returns
> successfully. This patch removes the fallback, which fixes kernel panics
> seen during stress tests. Hardware time stamping is not affected by this
> removal.
> 
> Signed-Off: Patrick Ohly <patrick.ohly@intel.com>
> Signed-Off: Emil Tantilov <emil.s.tantilov@intel.com>

It's "Signed-of-by", three words, only the first capitalized.

Aplied, thanks.
