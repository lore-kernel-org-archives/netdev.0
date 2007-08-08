From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipvs: force read of atomic_t in while loop
Date: Wed, 08 Aug 2007 03:21:31 -0700 (PDT)
Message-ID: <20070808.032131.35507346.davem@davemloft.net>
References: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au
To: heiko.carstens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754598AbXHHKVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 06:21:31 -0400
In-Reply-To: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Wed, 8 Aug 2007 11:33:00 +0200

> Just saw this while grepping for atomic_reads in a while loops.
> Maybe we should re-add the volatile to atomic_t. Not sure.

I think whatever the choice, it should be done consistently
on every architecture.

It's just asking for trouble if your arch does it differently from
every other.
