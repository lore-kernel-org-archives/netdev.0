From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: ARP monitoring broken on x86_64
Date: Fri, 26 Jan 2007 13:58:25 -0800
Message-ID: <200701262158.l0QLwP22009461@death.nxdomain.ibm.com>
References: <20070126144630.GA30601@gospo.rdu.redhat.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, michael.monnerie@it-management.at
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44771 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbXAZV7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 16:59:51 -0500
In-reply-to: <20070126144630.GA30601@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>While working with the latest bonding code I noticed a nasty problem
>that will prevent arp monitoring from always functioning correctly on
>x86_64 systems. Comparing ints to longs and expecting reliable results
>on x86_64 is a bad idea. With this patch, arp monitoring works correctly
>again.  
>
>This also needs to make its way into the 2.6.19 stable series.
>
>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Acked-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
