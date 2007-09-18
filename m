From: David Miller <davem@davemloft.net>
Subject: Re: new NAPI interface broken
Date: Tue, 18 Sep 2007 12:08:10 -0700 (PDT)
Message-ID: <20070918.120810.108807713.davem@davemloft.net>
References: <200709071137.02801.ossthema@de.ibm.com>
	<20070914.151252.85399360.davem@davemloft.net>
	<200709181815.45954.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	themann@de.ibm.com, raisch@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51614
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754662AbXIRTIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 15:08:25 -0400
In-Reply-To: <200709181815.45954.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Tue, 18 Sep 2007 18:15:45 +0200

> One other thing I observed is that I can not unload the module as the
> ref counter of the eth device is too low. I haven't tracked down the 
> source of this problem yet.

This is probably because of the resched device refcounting
bug that Roland Dreier just posted a fix for.

Look for subject "Fix refcounting problem with netif_rx_reschedule()"

I merge that in shortly to net-2.6.24 as well.
