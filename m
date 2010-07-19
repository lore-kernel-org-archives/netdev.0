From: David Miller <davem@davemloft.net>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 12:27:17 -0700 (PDT)
Message-ID: <20100719.122717.180390809.davem@davemloft.net>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
	<1279561319.2553.153.camel@edumazet-laptop>
	<AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54156
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965355Ab0GST1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 15:27:01 -0400
In-Reply-To: <AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 19 Jul 2010 11:44:05 -0700

> I am thinking of a device that supports multi-queue where individual
> queues can be programming to accept an exact 4-tuple,

NIU can already do this by programming the TCAM and segregating the
queues the TCAM entries map to.

There has also been talk of just having "a lot" of queues.  Maybe, on
the order of thousands.
