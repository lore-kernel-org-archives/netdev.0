From: David Miller <davem@davemloft.net>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Mon, 19 Oct 2009 19:23:44 -0700 (PDT)
Message-ID: <20091019.192344.193705436.davem@davemloft.net>
References: <4AD9B37A.3090606@gmail.com>
	<Pine.LNX.4.58.0910171709190.10440@u.domain.uli>
	<4ADCC58B.2060408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, w@1wt.eu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38303
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757229AbZJTCXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 22:23:22 -0400
In-Reply-To: <4ADCC58B.2060408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Oct 2009 22:01:15 +0200

> David, I think we should revert 6d01a026b7d3009a418326bdcf313503a314f1ea
> (tcp: fix tcp_defer_accept to consider the timeout) 
> since we know its broken.

I've reverted that patch and applied Julian's three tcp
patches, thanks!
