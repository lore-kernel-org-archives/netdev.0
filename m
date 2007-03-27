From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [NET] fib_rules: goto rule action
Date: Mon, 26 Mar 2007 23:08:27 -0700 (PDT)
Message-ID: <20070326.230827.98554151.davem@davemloft.net>
References: <20070326235713.478149847@lsx.localdomain>
	<20070326.171916.104032809.davem@davemloft.net>
	<460899D3.60808@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965242AbXC0GI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 02:08:28 -0400
In-Reply-To: <460899D3.60808@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 26 Mar 2007 21:13:07 -0700

> Do we have to worry about self inflicted infinite loops?
> Shouldn't there be some way to some basic validation?

We do, and there is.  You obviously didn't read Thomas's patch.

He prevents loops by only allowing forward gotos.
