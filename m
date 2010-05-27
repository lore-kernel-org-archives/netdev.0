From: David Miller <davem@davemloft.net>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Thu, 27 May 2010 13:35:59 -0700 (PDT)
Message-ID: <20100527.133559.193700421.davem@davemloft.net>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
	<20100527180545.GA2345@sysclose.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
To: fbl@sysclose.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758722Ab0E0Ufu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 16:35:50 -0400
In-Reply-To: <20100527180545.GA2345@sysclose.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@sysclose.org>
Date: Thu, 27 May 2010 15:05:45 -0300

> I did the following patch to discard the packet if it was IN_NETPOLL
> and the read_lock() fails, so I could go ahead testing it:

This is disgusting, let's just disallow console output from such
locations.  Defer them to a workqueue if their output is so critical.
