From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Thu, 24 Apr 2008 18:28:57 -0700 (PDT)
Message-ID: <20080424.182857.83348182.davem@davemloft.net>
References: <1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>
	<20080422.205945.229828014.davem@davemloft.net>
	<87ej8uyjvv.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46037
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751571AbYDYB25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 21:28:57 -0400
In-Reply-To: <87ej8uyjvv.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 25 Apr 2008 00:21:08 +0200

> That just means Linux does too much queueing by default.  Perhaps that
> should be fixed. On Ethernet hardware the NIC TX queue should be
> usually sufficient anyways I would guess. Do we really need the long
> qdisc queue too?

It is definitely an area that deserves attention and a real
investigation, that's for sure.

I spent a lot of time looking at the behavior in this area
while writing the NIU 10G driver.  As usual, I got distracted
before I could make any real experiments.

I'll try to get back to this if someone else doesn't beat
me to it.  We also have the TX multiqueue stuff to move
forward, and it's deeply related to these issues.
