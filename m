From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:20:59 -0700 (PDT)
Message-ID: <20070829.152059.48818008.davem@davemloft.net>
References: <200708292052.NAA21975@tardy.cup.hp.com>
	<5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
	<46D5EEB6.3020602@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56692
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759458AbXH2WVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 18:21:02 -0400
In-Reply-To: <46D5EEB6.3020602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 29 Aug 2007 15:09:58 -0700

> If nothing else, 200 ms is a "principle of least surprise" thing since 
> that is the current value (in MS) for TCP_RTO_MIN.

And Solaris and MacOS-X and...

In fact this is a great example why we don't treat RFCs as dictations
from the gods.  They are often wrong, impractical, or full of fatal
flaws.
