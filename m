From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] [TPROXY] kick out TIME_WAIT sockets in case a new
 connection comes in with the same tuple
Date: Tue, 09 Dec 2008 22:18:38 -0800 (PST)
Message-ID: <20081209.221838.206534714.davem@davemloft.net>
References: <1228812695.7631.16.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tproxy@lists.balabit.hu, hidden@sch.bme.hu,
	panther@balabit.hu
To: bazsi@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58575
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751093AbYLJGSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 01:18:37 -0500
In-Reply-To: <1228812695.7631.16.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balazs Scheidler <bazsi@balabit.hu>
Date: Tue, 09 Dec 2008 08:51:35 +0000

> Hi,
> 
> I'd like to get some guidance regarding the following patch. There's a 
> severe performance limitation related to TIME_WAIT sockets and TProxy rules.
> The patch below is the 'nice' approach, but it adds 6 bytes to 
> inet_sock and inet_timewait_sock. The 'ugly' approach would be to schedule the
> removal of the affected TIME_WAIT sockets at PREROUTING time.
> 
> This post is meant to get some review, but please do not apply this patch this time.

I have no general objection to this, but people seem to be
experts at making various parts of the TCP socket structures
larger and larger :-(
