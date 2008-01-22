From: David Miller <davem@davemloft.net>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in 2.6.24-rc6,
 comparing with 2.6.22
Date: Mon, 21 Jan 2008 22:22:14 -0800 (PST)
Message-ID: <20080121.222214.184161381.davem@davemloft.net>
References: <478B9FE0.3040801@hp.com>
	<1200979482.3151.103.camel@ymzhang>
	<1200982039.3151.120.camel@ymzhang>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: yanmin_zhang@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60200
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752217AbYAVGWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 01:22:08 -0500
In-Reply-To: <1200982039.3151.120.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Tue, 22 Jan 2008 14:07:19 +0800

> I am wondering if UDP stack in kernel has a bug.

If one server binds to INADDR_ANY with port N, then any other socket
can be bound to a specific IP address with port N.  When packets
come in destined for port N, the delivery will be prioritized
to whichever socket has the more specific and matching binding.

So the kernel is fine.

Netperf just needs to be more careful in order to handle this kind of
case more cleanly.
