From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Wed, 04 Jun 2008 01:17:17 +0900 (JST)
Message-ID: <20080604.011717.77875207.yoshfuji@linux-ipv6.org>
References: <20080602165249.52a467dc@extreme>
	<20080602165347.5662f602@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58010 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbYFCQQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:16:40 -0400
In-Reply-To: <20080602165347.5662f602@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080602165347.5662f602@extreme> (at Mon, 2 Jun 2008 16:53:47 -0700), Stephen Hemminger <shemminger@vyatta.com> says:

> Similar to previous change for IPV4. Allow configuration option to remove
> addresses from FIB when carrier is lost.
> 
> This patch also makes IPV6 ignore changes to carrier state when device
> is admin down state. This prevents address configuration from starting
> up on a buggy device driver that signals carrier changes when offline.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Well, we need to be careful here.
IMHO we should not remove addresses (especially link-local address
based on MAC, or manually assigned addresses, maybe).
We might want to do Optimistic DAD here.

--yoshfuji
