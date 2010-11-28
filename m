From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-26] cxgb4vf: fix setting unicast/multicast
 addresses ...
Date: Sun, 28 Nov 2010 11:40:32 -0800 (PST)
Message-ID: <20101128.114032.258097865.davem@davemloft.net>
References: <1290637437-2415-1-git-send-email-leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41712
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754095Ab0K1TkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 14:40:06 -0500
In-Reply-To: <1290637437-2415-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Wed, 24 Nov 2010 14:23:57 -0800

> We were truncating the number of unicast and multicast MAC addresses
> supported.  Additionally, we were incorrectly computing the MAC Address
> hash (a "1 << N" where we needed a "1ULL << N").
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

I'll apply this, thanks.
