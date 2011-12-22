From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Fix bug in ofo queue pruning MIB stats
Date: Wed, 21 Dec 2011 22:15:11 -0500 (EST)
Message-ID: <20111221.221511.1067604757446412302.davem@davemloft.net>
References: <1324511401-2640-1-git-send-email-subramanian.vijay@gmail.com>
	<20111221.193315.2134174670572741208.davem@davemloft.net>
	<CAGK4HS8g41A8KB9iqyabZN85Ytgb+HPk3wwvoOuwkk8s9+iuCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab1LVDPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 22:15:47 -0500
In-Reply-To: <CAGK4HS8g41A8KB9iqyabZN85Ytgb+HPk3wwvoOuwkk8s9+iuCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Wed, 21 Dec 2011 17:14:05 -0800

> If the counter is tracking the right thing, is it worth fixing
> netstat?

Probably.

The thing is, I can see both intepretations being useful.

If we count packets, we can't tell that OFO pruning happened 4 times
vs. we pruned 4 packets.

But if you want to know the "extent" to which OFO pruning occurs, then
you want the packet count.
