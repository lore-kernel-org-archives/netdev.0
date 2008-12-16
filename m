From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 09/14] gianfar: Add macros for stepping through
 BDs
Date: Tue, 16 Dec 2008 15:33:47 -0800 (PST)
Message-ID: <20081216.153347.95023702.davem@davemloft.net>
References: <1229469667-25002-8-git-send-email-afleming@freescale.com>
	<1229469667-25002-9-git-send-email-afleming@freescale.com>
	<1229469667-25002-10-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40671
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754153AbYLPXdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:33:46 -0500
In-Reply-To: <1229469667-25002-10-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:21:02 -0600

> This code is based strongly on code from Dai Haruki <Dai.Haruki@freescale.com>.
> 
> The gianfar Buffer Descriptors are arranged in a circular array, the end of
> which is denoted by setting the "WRAP" bit in the descriptor.  However, the
> software knows the end of the ring because it knows how many descriptors are
> there.  Rather than check each descriptor for whether the WRAP bit is set,
> use pointer math to determine where the next BD is.  This is also useful for
> when we want to look at BDs other than the very next one (for Scatter-Gather).
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
