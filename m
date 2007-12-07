From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/6] ipv6 - make xfrm6_init to return an error code
Date: Fri, 07 Dec 2007 00:42:21 -0800 (PST)
Message-ID: <20071207.004221.90815794.davem@davemloft.net>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071206140254.504102655@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751512AbXLGImW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:42:22 -0500
In-Reply-To: <20071206140254.504102655@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 06 Dec 2007 14:53:31 +0100

> The xfrm initialization function does not return any error code, so
> if there is an error, the caller can not be advise of that.
> This patch checks the return code of the different called functions
> in order to return a successful or failed initialization.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks.
