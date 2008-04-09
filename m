From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Eliminate fast-path print_mac() pr_debug()'s.
Date: Tue, 08 Apr 2008 17:11:55 -0700 (PDT)
Message-ID: <20080408.171155.115783629.davem@davemloft.net>
References: <20080408.165453.215068738.davem@davemloft.net>
	<1207699726.1020.157.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752490AbYDIALy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 20:11:54 -0400
In-Reply-To: <1207699726.1020.157.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 08 Apr 2008 17:08:46 -0700

> If you'd have waited about 1/2 hour you would have received
> the change I had already done which fixes just the fast path
> pr_debug calls rather than what you did, which touches a
> bunch of not fast path printks.

I validated that everything I touched was in a packet
processing path, and therefore potentially "hot"
depending upon what you use your system for.
