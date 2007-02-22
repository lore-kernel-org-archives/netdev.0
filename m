From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP : keep copied_seq, rcv_wup and rcv_next together
Date: Thu, 22 Feb 2007 03:02:12 -0800 (PST)
Message-ID: <20070222.030212.130230755.davem@davemloft.net>
References: <200702221122.02806.dada1@cosmosbay.com>
	<20070222.023220.92577095.davem@davemloft.net>
	<200702221143.32622.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933015AbXBVLCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:02:16 -0500
In-Reply-To: <200702221143.32622.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 22 Feb 2007 11:43:32 +0100

> I wonder if :
> 
> newtp->snd_nxt = newtp->snd_una = newtp->snd_sml = treq->snt_isn + 1;
> 
> is correct, since compiler will write snd_sml, then snd_una, and snd_nxt
> 
> Maybe we should also reorder this too ?

Yes, that appears necessary.

