From: David Miller <davem@davemloft.net>
Subject: Re: Possible deadlock in ipv6?
Date: Wed, 20 Jun 2012 21:05:52 -0700 (PDT)
Message-ID: <20120620.210552.612891057039503955.davem@davemloft.net>
References: <1338998314.26966.12.camel@edumazet-glaptop>
	<20120611.235453.953830769326224643.davem@davemloft.net>
	<1339492184.22704.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vdavydov@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab2FUEFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 00:05:53 -0400
In-Reply-To: <1339492184.22704.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Jun 2012 11:09:44 +0200

> Is it expected we send traffic on device dismantle ?

If we are subscribed to multicast groups we could, to
announce our leaving those groups.
