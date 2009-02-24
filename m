From: David Miller <davem@davemloft.net>
Subject: Re: oops / null deref in __inet6_check_established(), kernel
 2.6.29-rc6
Date: Tue, 24 Feb 2009 15:27:04 -0800 (PST)
Message-ID: <20090224.152704.210992553.davem@davemloft.net>
References: <20090224182147.2150468e@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752894AbZBXX1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 18:27:21 -0500
In-Reply-To: <20090224182147.2150468e@dhcp-100-2-144.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chuck Ebbert <cebbert@redhat.com>
Date: Tue, 24 Feb 2009 18:21:47 -0500

> (This doesn't happen on 2.6.27/28)
> 
> tw is NULL at net/ipv6/inet6_hashtables.c:261:
> 
> 	if (twp != NULL) {
> 		*twp = tw;
> ===>		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
> 	} else if (tw != NULL) {
> 
> I can reproduce this on real hardware on x86_64 too...

How? :-)
