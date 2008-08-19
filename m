From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 22:39:28 -0700 (PDT)
Message-ID: <20080818.223928.247389617.davem@davemloft.net>
References: <20080818125805.GA7938@ff.dom.local>
	<20080818.165638.169012226.davem@davemloft.net>
	<20080819053745.GA2722@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752654AbYHSFj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 01:39:28 -0400
In-Reply-To: <20080819053745.GA2722@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 19 Aug 2008 05:37:45 +0000

> As a matter of fact, I still have some doubts about this. Top level
> qdiscs must be deactivated before destroy and during this process we
> make sure nothing can use them anymore. So, since this all is under
> rtnl_lock(), I wonder if we really need this qdisc root_lock around
> qdisc_destroy() for root qdiscs at all.

Read the read of your inbox :-)
