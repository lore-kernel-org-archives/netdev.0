From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] sit/gre6: don't try to add the same route two
 times
Date: Thu, 14 Nov 2013 16:59:44 -0500 (EST)
Message-ID: <20131114.165944.2246055116999000460.davem@davemloft.net>
References: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
	<1384433467-4780-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637Ab3KNV7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:59:46 -0500
In-Reply-To: <1384433467-4780-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 14 Nov 2013 13:51:07 +0100

> addrconf_add_linklocal() already adds the link local route, so there is no
> reason to add it before calling this function.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
