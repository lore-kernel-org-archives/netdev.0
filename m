From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 15907] New: IP_ADD_SOURCE_MEMBERSHIP after
 IP_ADD_MEMBERSHIP join on same multicast-group dont return EINVAL
Date: Fri, 07 May 2010 18:49:14 -0700 (PDT)
Message-ID: <20100507.184914.236232473.davem@davemloft.net>
References: <OFD4CF7550.98F2D787-ON8825771A.005CD3AE-8825771A.005E4045@us.ibm.com>
	<OFF6B69D4E.4BD995AD-ON8825771C.0081F4BF-8825771C.0082FBC7@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, shemminger@vyatta.com
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41156
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751062Ab0EHBtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 21:49:08 -0400
In-Reply-To: <OFF6B69D4E.4BD995AD-ON8825771C.0081F4BF-8825771C.0082FBC7@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Fri, 7 May 2010 16:50:44 -0700

>         Do you have an opinion on this one? Linux code (for many
> years now) allows you to do SSM calls after an ordinary ASM join,
> and vice-versa. The bugzilla basically wants to see mixing the calls
> return EINVAL.

We can't do that.

It will obviously break existing applications.

Someone please close the bug.
