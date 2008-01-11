From: David Miller <davem@davemloft.net>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Thu, 10 Jan 2008 17:28:30 -0800 (PST)
Message-ID: <20080110.172830.16409182.davem@davemloft.net>
References: <1199981839.8931.35.camel@cafe>
	<36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756190AbYAKB2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 20:28:36 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Thu, 10 Jan 2008 12:52:15 -0800

> I hope this explanation makes sense, but what it comes down to is that
> combining hardware round robin balancing with NAPI is a BAD IDEA.

Absolutely agreed on all counts.

No IRQ balancing should be done at all for networking device
interrupts, with zero exceptions.  It destroys performance.
