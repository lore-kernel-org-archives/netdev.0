From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] ipconfig wait for carrier
Date: Thu, 19 May 2011 16:19:50 -0400 (EDT)
Message-ID: <20110519.161950.242667682596117811.davem@davemloft.net>
References: <1305405386-25187-1-git-send-email-micha@neli.hopto.org>
	<1305836046-21136-1-git-send-email-micha@neli.hopto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: micha@neli.hopto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933926Ab1ESUT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:19:57 -0400
In-Reply-To: <1305836046-21136-1-git-send-email-micha@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Micha Nelissen <micha@neli.hopto.org>
Date: Thu, 19 May 2011 22:14:06 +0200

> v3 -> v4: fix return boolean false instead of 0 for ic_is_init_dev
> 
> Currently the ip auto configuration has a hardcoded delay of 1 second.
> When (ethernet) link takes longer to come up (e.g. more than 3 seconds),
> nfs root may not be found.
> 
> Remove the hardcoded delay, and wait for carrier on at least one network
> device.
> 
> Signed-off-by: Micha Nelissen <micha@neli.hopto.org>
> Cc: David Miller <davem@davemloft.net>

Ok, I've applied this, let's see what happens.
