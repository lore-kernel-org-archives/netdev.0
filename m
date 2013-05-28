From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: allow xmit hash policy change while
 bond dev is up
Date: Mon, 27 May 2013 23:27:37 -0700 (PDT)
Message-ID: <20130527.232737.1170202270569404967.davem@davemloft.net>
References: <1369393187-23163-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933029Ab3E1G1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:27:38 -0400
In-Reply-To: <1369393187-23163-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nikolay@redhat.com
Date: Fri, 24 May 2013 12:59:47 +0200

> From: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Since the xmit_hash_policy pointer is always valid and not dependent on
> anything, we can change it while the bond device is up and running. The
> only downside would be the out of order packets but that is a small price
> to pay.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Looks reasonable, applied, thanks!
