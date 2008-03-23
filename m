From: David Miller <davem@davemloft.net>
Subject: Re: O(n^2) or worse ? cat /proc/net/tcp
Date: Sun, 23 Mar 2008 16:20:21 -0700 (PDT)
Message-ID: <20080323.162021.184196552.davem@davemloft.net>
References: <20080323224307.GL3700@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.aarnio@zmailer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756284AbYCWXUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 19:20:04 -0400
In-Reply-To: <20080323224307.GL3700@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Aarnio <matti.aarnio@zmailer.org>
Date: Mon, 24 Mar 2008 00:43:07 +0200

> I have about 750 TCP socket on one multi-threaded server application, and 
> about 250 on three single-threaded clients.
> 
> I did observe odd slowness at first with  "lsof -p .."  program, then at
> "netstat -na".  Same slowdown happens with:  cat /proc/net/tcp
> (that 'cat' took 25 seconds...)
> 
> Sure this is not earth shatterinly dangerous thing, rather a nuisance
> when a monitoring application is not as fast as one would expect.

There have been some improvements in this area over the
past few releases.

If you tell us what version you're running we can try to
dig out the changes that matter.
