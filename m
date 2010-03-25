From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RPS: support 802.1q and pppoe session
Date: Wed, 24 Mar 2010 21:50:01 -0700 (PDT)
Message-ID: <20100324.215001.82823131.davem@davemloft.net>
References: <4BAAE6E9.6030103@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46008
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751434Ab0CYEtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 00:49:39 -0400
In-Reply-To: <4BAAE6E9.6030103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 25 Mar 2010 12:30:33 +0800

> support 802.1q and pppoe session
> 
> Support 802.1q and pppoe session, and these two protocols can get the
> benefit from RPS.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

This is getting rediculious.

The TX hasher doesn't support this, neither should RPS.

Most of the patches you've been posting to RPS are very specialized
hacks and frankly not very welcome.
