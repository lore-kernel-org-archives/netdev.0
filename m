From: David Miller <davem@davemloft.net>
Subject: Re: RTA_SRC doesn't work?
Date: Thu, 02 May 2013 16:21:01 -0400 (EDT)
Message-ID: <20130502.162101.1494997915474101391.davem@davemloft.net>
References: <7iy5bx6xnk.wl%jch@pps.univ-paris-diderot.fr>
	<20130502.152129.1771626992982436220.davem@davemloft.net>
	<7ippx96tmo.wl%jch@pps.univ-paris-diderot.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jch@pps.jussieu.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762083Ab3EBUVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 16:21:05 -0400
In-Reply-To: <7ippx96tmo.wl%jch@pps.univ-paris-diderot.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Juliusz Chroboczek <jch@pps.jussieu.fr>
Date: Thu, 02 May 2013 21:58:55 +0200

>> >   $ sudo ip route add default from 172.23.36.54/32 dev eth0
>> >   RTNETLINK answers: File exists
>> >   $
> 
>> Do you already have a default route on eth0 when you run this?
> 
> Yes, one that is not source-specific.

Doesn't matter, you can't have multiple routes with the same lookup
keys.
