From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [SCTP]: Do not timestamp every SCTP packet.
Date: Fri, 29 Sep 2006 17:10:11 -0700 (PDT)
Message-ID: <20060929.171011.51841403.davem@davemloft.net>
References: <1159560037.29637.52.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20363
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932410AbWI3AKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 20:10:09 -0400
To: sri@us.ibm.com
In-Reply-To: <1159560037.29637.52.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 29 Sep 2006 13:00:37 -0700

> [SCTP]: Do not timestamp every SCTP packet.
> 
> We only need the timestamp on COOKIE-ECHO chunks, so instead of always
> timestamping every SCTP packet, let common code timestamp if the socket
> option is set.  For COOKIE-ECHO, simply get the time of day if we don't
> have a timestamp.  This introduces a small possibility that the cookie
> may be considered expired, but it will be renegotiated.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Also applied, thanks a lot.
