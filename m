From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] bridge: Use the correct bit length for bitmap
 functions in the VLAN code
Date: Tue, 20 Aug 2013 23:36:59 -0700 (PDT)
Message-ID: <20130820.233659.1757125533943263798.davem@davemloft.net>
References: <1376986060.5740.7.camel@ubuntu-vm-makita>
	<1376986218.5740.9.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174Ab3HUGhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:37:00 -0400
In-Reply-To: <1376986218.5740.9.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue, 20 Aug 2013 17:10:18 +0900

> The VLAN code needs to know the length of the per-port VLAN bitmap to
> perform its most basic operations (retrieving VLAN informations, removing
> VLANs, forwarding database manipulation, etc). Unfortunately, in the
> current implementation we are using a macro that indicates the bitmap
> size in longs in places where the size in bits is expected, which in
> some cases can cause what appear to be random failures.
> Use the correct macro.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied and queued up for -stable, thank you.
