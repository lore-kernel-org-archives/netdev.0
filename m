From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] sctp: use transport hashtable to replace
 association's with rhashtable
Date: Wed, 30 Dec 2015 15:40:14 -0500 (EST)
Message-ID: <20151230.154014.1155079588447705262.davem@davemloft.net>
References: <1451495979.8255.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151230.125204.1385006803109278855.davem@davemloft.net>
	<1451502223.8255.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, mleitner@redhat.com,
	vyasevic@redhat.com, daniel@iogearbox.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755063AbbL3UkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 15:40:18 -0500
In-Reply-To: <1451502223.8255.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Dec 2015 14:03:43 -0500

> You sure can disagree with me, but calling my opinion 'incredily
> stupid' is not wise.

I think fundamentally giving facilities less rather than more coverage
is not a smart approach at all.

If the code is that bad that people are discouraged from even using
it, then it should be moved to drivers/staging or removed.  Otherwise
it must work and we must be able to make use of it.

> I understand we would love to do that, but what is the hurry for
> SCTP, that needed rhashtable so desperately that it could not be
> done before 2016 ?

There is no rush, but quite frankly finding people to do serious
work on SCTP is no easy task so I'm hesitant to "defer" someone's
work in this area... :-)
