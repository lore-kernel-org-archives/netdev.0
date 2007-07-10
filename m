From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [IPV6]: Restore semantics of Routing Header
 processing.
Date: Mon, 09 Jul 2007 20:42:31 -0700 (PDT)
Message-ID: <20070709.204231.41644679.davem@davemloft.net>
References: <4676CBFD.1040901@hp.com>
	<20070709.143250.132417671.davem@davemloft.net>
	<4692E087.8080908@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754852AbXGJDmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 23:42:09 -0400
In-Reply-To: <4692E087.8080908@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 09 Jul 2007 21:27:35 -0400

> Yes, but the addition of the sysctl was an overreaction.

Disagreed, we have controls like this and also things like netfilter
that in most cases do not make any sense at all, yet are useful to
some people in specialized environments, and even are discouraged by
RFCs.

Again, there is no reason to object to this part of the changes.

If you think not putting in sysctls like this makes people not
block this stuff, think again.
