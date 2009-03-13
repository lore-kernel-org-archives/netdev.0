From: David Miller <davem@davemloft.net>
Subject: Re: VIA velocity skb leak.
Date: Fri, 13 Mar 2009 13:36:40 -0700 (PDT)
Message-ID: <20090313.133640.130060599.davem@davemloft.net>
References: <49B89385.4090005@cosmosbay.com>
	<20090312045657.GB7132@redhat.com>
	<49B89A33.2030207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751549AbZCMUgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 16:36:54 -0400
In-Reply-To: <49B89A33.2030207@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 12 Mar 2009 06:14:27 +0100

> or use max_t(unsigned, skb->len, ETH_ZLEN)

Right, I'll add Dave's patch, but using max_t() here.

Thanks everyone.
