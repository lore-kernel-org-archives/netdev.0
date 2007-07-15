From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] lro: Generic Large Receive Offload for TCP traffic
Date: Sun, 15 Jul 2007 02:40:15 -0700 (PDT)
Message-ID: <20070715.024015.126137834.davem@davemloft.net>
References: <200707111621.24852.ossthema@de.ibm.com>
	<20070714.235748.02297780.davem@davemloft.net>
	<20070715091253.GA15790@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756722AbXGOJkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 05:40:12 -0400
In-Reply-To: <20070715091253.GA15790@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 15 Jul 2007 10:12:53 +0100

> I'm not sure that's a good idea.  If current chips can't handle ipv6
> lro there is no way to actually test it and the code will surely bitrot.

Christoph, you can do LRO pretty much completely in software.

