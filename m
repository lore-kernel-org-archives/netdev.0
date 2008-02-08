From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED] Traffic Control subsystem Notifier for Kernel
 Modules
Date: Fri, 08 Feb 2008 00:24:04 -0800 (PST)
Message-ID: <20080208.002404.241903230.davem@davemloft.net>
References: <1202455182-13379-1-git-send-email-yashpal.dutta@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.phillips@freescale.com
To: yashpal.dutta@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55274
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933073AbYBHIXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 03:23:33 -0500
In-Reply-To: <1202455182-13379-1-git-send-email-yashpal.dutta@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yashpal Dutta <yashpal.dutta@freescale.com>
Date: Fri,  8 Feb 2008 12:49:42 +0530

> The patch adds raw notifiers in Traffic Control subsystem for communicating
> Queue Disciplines and Classifiers added by user via TC application.
> Interested kernel modules will have to register to the TC subsystem
> to be able to get new QDisc notifys asynchronously.
> 
> Signed-off-by: Yashpal Dutta <yashpal.dutta@freescale.com>
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>

You can simply listen on the appropriate netlink socket for these
events already.  There is no reason I can see to provide them over a
different framework like this.
