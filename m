From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reflect the fwmark for replies with no socket
Date: Mon, 17 Mar 2014 14:55:22 -0400 (EDT)
Message-ID: <20140317.145522.584337331452843243.davem@davemloft.net>
References: <1394536541-25702-1-git-send-email-lorenzo@google.com>
	<20140312.161737.1125059989320204564.davem@davemloft.net>
	<CAKD1Yr2rSwpzSdvjsO-=QUkivAkw2gnj+_mvydtR8OfAnsTicg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaCQSza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 14:55:30 -0400
In-Reply-To: <CAKD1Yr2rSwpzSdvjsO-=QUkivAkw2gnj+_mvydtR8OfAnsTicg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Mon, 17 Mar 2014 14:24:57 +0900

> In general, that's true. Still - currently the mark on these packets
> is 0, period, and the administrator can't do anything about that at
> all. The idea was that some control is better than zero control, and
> since these packets are always in reply to other packets, then marking
> responses based on the packets that provoked them made sense, since
> the input marking can be as flexible as the administrator desires.

I do not agree with this assesment at all, a default of 0 is better
than an potentially undesirable default.

The incoming fwmark is controlled by external entities, and most people
are usually unhappy with external entities having influence upon their
machine's behavior.
