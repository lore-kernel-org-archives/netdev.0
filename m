From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-2.6.26] [XFRM]: Compilation warnings in
 xfrm_user.c.
Date: Mon, 14 Apr 2008 14:52:11 -0700 (PDT)
Message-ID: <20080414.145211.248838386.davem@davemloft.net>
References: <1208178219-18754-1-git-send-email-den@openvz.org>
	<200804141035.46671.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51264
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751926AbYDNVwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 17:52:09 -0400
In-Reply-To: <200804141035.46671.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Mon, 14 Apr 2008 10:35:46 -0400

> Thanks for catching this, I was focusing more on the runtime issues with 
> the else statement and forgot about compile time issues.  I wonder if 
> it would be better to fix this in the dummy function for 
> security_xfrm_policy_alloc()?  It seems cleaner to me.

I think in this specific case the choice is arbitrary, which is
why I applied his patch.
