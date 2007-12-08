From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3][IPV6]: remove ifdef in route6 for xfrm6
Date: Sat, 08 Dec 2007 00:14:21 -0800 (PST)
Message-ID: <20071208.001421.252922091.davem@davemloft.net>
References: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071207131812.456058639@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45076
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754173AbXLHIOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:14:22 -0500
In-Reply-To: <20071207131812.456058639@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Fri, 07 Dec 2007 14:13:27 +0100

> The following patch create the usual static inline functions to disable
> the xfrm6_init and xfrm6_fini function when XFRM is off.
> That's allow to remove some ifdef and make the code a little more clear.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
