From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 14:38:50 -0700 (PDT)
Message-ID: <20070515.143850.35508549.davem@davemloft.net>
References: <ada8xbppynm.fsf@cisco.com>
	<OF21D475A2.5E5C88DE-ON872572DC.00763DE4-882572DC.00768A7E@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: xma@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47935
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754403AbXEOVip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:38:45 -0400
In-Reply-To: <OF21D475A2.5E5C88DE-ON872572DC.00763DE4-882572DC.00768A7E@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <xma@us.ibm.com>
Date: Tue, 15 May 2007 14:35:13 -0700

>       I would think it might be better to implement dequeueN in
> interface xmit which will benefit multiple streams as well not just
> for large packet.

I think it is beneficial to have both, each of them helps with
different aspects of packet sending overhead.
