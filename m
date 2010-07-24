From: David Miller <davem@davemloft.net>
Subject: Re: pktgen performance hit due to memset.
Date: Fri, 23 Jul 2010 18:51:42 -0700 (PDT)
Message-ID: <20100723.185142.193690342.davem@davemloft.net>
References: <4C4A224B.8080806@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53982
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755960Ab0GXBv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 21:51:26 -0400
In-Reply-To: <4C4A224B.8080806@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 23 Jul 2010 16:14:19 -0700

> Some time back, someone added some memset() calls to pktgen to
> keep from leaking memory contents to the network.
> 
> At least in our modified version of pktgen, this caused about 25%
> performance degradation when sending 1514 byte pkts (multi-pkt == 0)
> on a pair of 10G ports.  It was easy enough to comment these memset
> calls out of course.
> 
> I don't mind if this patch stays in,
> but thought I'd post my findings in case anyone else wonders why
> their pktgen slowed down...

Thanks for the data point Ben.
