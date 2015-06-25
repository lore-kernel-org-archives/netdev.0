From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Get rid of sock->sk_protinfo.
Date: Thu, 25 Jun 2015 06:18:34 -0700 (PDT)
Message-ID: <20150625.061834.415041547180537449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, edumazet@google.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbbFYNGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 09:06:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These two patches get rid of the last remaining user of sk_protinfo
(ax25) and then really gets rid of the struct member.

Signed-off-by: David S. Miller <davem@davemloft.net>
