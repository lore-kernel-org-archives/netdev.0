From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/7] skge: use per-port phy locking
Date: Fri, 23 Mar 2007 01:49:41 -0400
Message-ID: <46036A75.6030005@pobox.com>
References: <20070316210125.324052637@linux-foundation.org> <20070316210155.954697018@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60439 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753173AbXCWFtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:49:42 -0400
In-Reply-To: <20070316210155.954697018@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Rather than a workqueue and a per-board mutex to control PHY,
> use a tasklet and spinlock. Tasklet is lower overhead and works
> just as well for this.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Like we give a crap about overhead of PHY code.

This seems like the wrong direction to me, but let's see where this leads.

	Jeff



