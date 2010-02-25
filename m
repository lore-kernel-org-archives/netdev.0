From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked
 mode
Date: Wed, 24 Feb 2010 17:34:36 -0800 (PST)
Message-ID: <20100224.173436.212403104.davem@davemloft.net>
References: <29C1DC0826876849BDD9F1C67ABA2943070F0E2E@ala-mail09.corp.ad.wrs.com>
	<20100224185340.GB15380@hmsreliant.think-freely.org>
	<29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41913
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753199Ab0BYBeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 20:34:18 -0500
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Stephens, Allan" <allan.stephens@windriver.com>
Date: Wed, 24 Feb 2010 11:05:12 -0800

> Have you tried upgrading your system to use TIPC 1.7.6 (available at
> http://tipc.sourceforge.net/tipc_linux.html)?  This is a significant
> revised and enhanced version of TIPC that hasn't yet made its way into
> mainsteam Linux, and seems to be the version-of-choice for most TIPC
> users.  It also appears to avoid a number of the issues that currently
> exist in TIPC 1.6, including the one caused by the random configuration
> command you mentioned in your email below.
> 
> I didn't have a problem with you working on a small patch for TIPC 1.6
> to get around a limited problem, but I'd hate to see you waste time on
> fixing issues that have already been addressed in TIPC 1.7.

Why is the TIPC kernel protocol code being developed out of tree
instead of directly upstream?

Regardless of that, if the code is in the kernel tree and it can be
OOPS'd, we must fix it.
