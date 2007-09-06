From: David Miller <davem@davemloft.net>
Subject: Re: af_packet: don't enable global timestamps
Date: Thu, 06 Sep 2007 05:56:46 -0700 (PDT)
Message-ID: <20070906.055646.41629371.davem@davemloft.net>
References: <20070904063525.060e7a77@oldman>
	<20070904095958.53c86337.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ak@suse.de, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:46972
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751326AbXIFM5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 08:57:21 -0400
In-Reply-To: <20070904095958.53c86337.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 4 Sep 2007 09:59:58 +0200

> This patch seems the correct fix for this longstanding problem.
> 
> Please note that if wireshark/tcpdump processes really want precise timestamps, 
> they still can ask this by using setsockopt(SO_TIMESTAMP or SO_TIMESTAMPNS) on their private socket.
> 
> (We already know that running a sniffer has a cost anyway)

Agreed, let's give this a try.

I've applied Stephen's patch to net-2.6.24
