From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27] tcp_vegas ssthresh bug fix
Date: Thu, 04 Dec 2008 17:17:46 -0800 (PST)
Message-ID: <20081204.171746.256513842.davem@davemloft.net>
References: <650FA54C-402C-48CC-95AD-CA4AC5086BAD@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Doug.Leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752022AbYLEBRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 20:17:45 -0500
In-Reply-To: <650FA54C-402C-48CC-95AD-CA4AC5086BAD@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <Doug.Leith@nuim.ie>
Date: Fri, 05 Dec 2008 00:11:05 +0000

> This patch fixes a bug in tcp_vegas.c.  At the moment this code leaves ssthresh untouched.  However, this means that the vegas congestion control algorithm is effectively unable to reduce cwnd below the ssthresh value (if the vegas update lowers the cwnd below ssthresh, then slow start is activated to raise it back up).   One example where this matters is when during slow start cwnd overshoots the link capacity and a flow then exits slow start with ssthresh set to a value above where congestion avoidance would like to adjust it.
> 
> Signed-off-by:  Doug Leith <doug.leith@nuim.ie>

Nevermind, I see that you used an attachment, so I
applied this, but:

> --- net/ipv4/tcp_vegas.c.orig   2008-12-04 23:51:19.000000000 +0000
> +++ net/ipv4/tcp_vegas.c        2008-12-05 00:00:42.000000000 +0000

You really need to -p1 root your patches.
