From: David Miller <davem@davemloft.net>
Subject: Re: ARP response with link local IP, why not broadcast
Date: Wed, 22 Jul 2015 10:56:10 -0700 (PDT)
Message-ID: <20150722.105610.70610581544132934.davem@davemloft.net>
References: <55AE5958.3020009@gmx.de>
	<CACP96tRrCzFwTC-fSMxGTWr+zFSkid=Bd6JkGZA822HbEjk4_Q@mail.gmail.com>
	<55AF4B1D.4030208@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini05@gmail.com, netdev@vger.kernel.org
To: db_extern@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481AbbGVR4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 13:56:11 -0400
In-Reply-To: <55AF4B1D.4030208@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Fett <db_extern@gmx.de>
Date: Wed, 22 Jul 2015 09:49:49 +0200

> I think that behaviour is acceptable because it only happens in local
> networks. Waking up sleeping devices will not be a concern there.

No, it is not acceptable.

If your laptop or cell phone's wireless interface is sleeping, they
are on a "local" network and shouldn't be woken up.
