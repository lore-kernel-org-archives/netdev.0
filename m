From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sun, 29 Aug 2010 10:06:53 -0700 (PDT)
Message-ID: <20100829.100653.70199372.davem@davemloft.net>
References: <20100828101424.69c4c782@s6510>
	<20100828.144130.189711704.davem@davemloft.net>
	<20100829095951.GA3153@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753575Ab0H2RGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Aug 2010 13:06:37 -0400
In-Reply-To: <20100829095951.GA3153@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 29 Aug 2010 11:59:51 +0200

> Actually, when GRO compares napi->dev to skb->dev?

Hmmm, I thought the code made a skb->dev comparison with the
existing SKBs in the list when checking for same-flow matches.

It doesn't, probably based upon the assumption that a NAPI
instance maps to a unique device, the very topic we're
discussing right now :-/


