From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44.c box lockup fix (netconsole): ratelimit NAPI poll
 error message
Date: Wed, 25 Nov 2009 14:56:43 -0800 (PST)
Message-ID: <20091125.145643.04893966.davem@davemloft.net>
References: <20091125213546.GA6168@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, dave@thedillows.org, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45835
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759250AbZKYW4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 17:56:25 -0500
In-Reply-To: <20091125213546.GA6168@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andi@lisas.de>
Date: Wed, 25 Nov 2009 22:35:46 +0100

> Turns out that it's not very helpful to have a netconsole-deployed
> network driver's interrupt handler message spew noise permanently
> (see comment in patch).

It's not even an illegal state, especially with shared interrupts.
The warning should never be emitted.
