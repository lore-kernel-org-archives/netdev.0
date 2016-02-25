From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/5] ppp: lock ppp structure before modifying mru
 in ppp_ioctl()
Date: Thu, 25 Feb 2016 15:24:57 -0500 (EST)
Message-ID: <20160225.152457.207063136252739704.davem@davemloft.net>
References: <be5fc2cf38f44951ea15f366bc52fb4d780009d2.1456167043.git.g.nault@alphalink.fr>
	<20160224.153202.880408949435562278.davem@davemloft.net>
	<20160225191655.GA1462@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbcBYUY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 15:24:59 -0500
In-Reply-To: <20160225191655.GA1462@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 25 Feb 2016 20:16:55 +0100

> Understood. Just to be sure, does patch #2 falls under lack of
> demonstration? Or should I repost it separately?

Please repost it if you feel this way, with the race and corruption
possibility explained in detail in the commit log message.

Thanks.
