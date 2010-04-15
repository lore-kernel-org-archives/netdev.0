From: David Miller <davem@davemloft.net>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 01:51:17 -0700 (PDT)
Message-ID: <20100415.015117.107243799.davem@davemloft.net>
References: <1271271222.4567.51.camel@bigi>
	<20100414124426.6aee95c3@nehalam>
	<1271275130.16881.1749.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, hadi@cyberus.ca, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, xiaosuo@gmail.com,
	andi@firstfloor.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757513Ab0DOIvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:51:13 -0400
In-Reply-To: <1271275130.16881.1749.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Apr 2010 21:58:50 +0200

> Every time we change RPS to be on or off, we might have some extra
> noise. Maybe we already have this problem with irqbalance ?

irqbalance should never move network device interrupts around
under normal circumstances.  Arjan assured me that there is
specific logic in the irqbalance daemon to not move NIC
interrupts around once a target has been choosen.

