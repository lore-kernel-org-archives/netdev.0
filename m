From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 00:21:08 +0200
Message-ID: <87ej8uyjvv.fsf@basil.nowhere.org>
References: <480E8523.4030007@hp.com>
	<1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>
	<20080422.205945.229828014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnwheffner@gmail.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:38519 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbYDXWVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 18:21:11 -0400
In-Reply-To: <20080422.205945.229828014.davem@davemloft.net> (David Miller's message of "Tue, 22 Apr 2008 20:59:45 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

>> What is your interface txqueuelen and mtu?  If you have a very large
>> interface queue, TCP will happily fill it up unless you are using a
>> delay-based congestion controller.
>
> Yes, that's the fundamental problem with loss based congestion
> control.  If there are any queues in the path, TCP will fill them up.

That just means Linux does too much queueing by default.  Perhaps that
should be fixed. On Ethernet hardware the NIC TX queue should be
usually sufficient anyways I would guess. Do we really need the long
qdisc queue too?

-Andi
