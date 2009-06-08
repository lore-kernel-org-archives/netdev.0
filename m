From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Mon, 8 Jun 2009 11:20:31 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0906081117580.21954@gentwo.org>
References: <alpine.DEB.1.10.0906041150590.3204@gentwo.org> <20090604.153057.178458221.davem@davemloft.net> <alpine.DEB.1.10.0906050959380.23895@gentwo.org> <20090605.181613.147549237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:36630 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756497AbZFHPUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 11:20:37 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 80A7A82C3EF
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2009 11:35:59 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dgNxLUzHdqCe for <netdev@vger.kernel.org>;
	Mon,  8 Jun 2009 11:35:59 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5B2DB82C420
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2009 11:35:51 -0400 (EDT)
In-Reply-To: <20090605.181613.147549237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Jun 2009, David Miller wrote:

> It's fundamentally wrong.  You need some limit there.

Maybe we need a different approach but (since we are at the point of
talking about categorical fundamentally wrong statements) its
fundamentally wrong if the IPoIB layer works differently from a regular
Ethernet NIC. They should work in the same way.

Could the packet drop mechanism for multicast be removed from the device
drivers and made standard in the core net layer? So they all have the same
predictable behavior for the applications using multicast?

