From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 13:03:09 -0700 (PDT)
Message-ID: <20110606.130309.847468074358617705.davem@davemloft.net>
References: <1307389540.2642.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367Ab1FFUDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:03:15 -0400
In-Reply-To: <1307389540.2642.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jun 2011 21:45:40 +0200

> While trying Alexander Holler patch, I found a 32bit brctl program was
> not able to work on a 64bit kernel. So I had to switch to another
> machine for my tests.
> 
> brctl addbr mybridge
> ->
> socket(PF_FILE, SOCK_STREAM, 0)         = 3
> ioctl(3, SIOCSIFBR, 0xffd509c0)         = -1 EINVAL (Invalid argument)
> 
> Should we care or not ?

I think we should make an effort to fix this.
