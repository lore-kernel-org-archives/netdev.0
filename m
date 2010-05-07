From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Fw: [Bug 15907] New: IP_ADD_SOURCE_MEMBERSHIP after IP_ADD_MEMBERSHIP
 join on same multicast-group dont return EINVAL
Date: Fri, 7 May 2010 16:50:44 -0700
Message-ID: <OFF6B69D4E.4BD995AD-ON8825771C.0081F4BF-8825771C.0082FBC7@us.ibm.com>
References: <OFD4CF7550.98F2D787-ON8825771A.005CD3AE-8825771A.005E4045@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:33914 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab0EGXur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 19:50:47 -0400
In-Reply-To: <OFD4CF7550.98F2D787-ON8825771A.005CD3AE-8825771A.005E4045@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
        Do you have an opinion on this one? Linux code (for many years 
now)
allows you to do SSM calls after an ordinary ASM join, and vice-versa. The 
bugzilla
basically wants to see mixing the calls return EINVAL.
        That's not so hard to do, but if existing apps are mixing them, 
they, of
course, will fail. That's the intent of the RFC, but the code predates it 
and
happily converts between ASM and SSM automatically.
        So, I'm guessing the answer is "will not fix," but
it's your call. If you think we want to enforce this, I'll do
a patch.
        The original post is here:

http://marc.info/?l=linux-netdev&m=127307292215281&w=2

                                                        +-DLS

