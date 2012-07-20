From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: show pmtu in route list
Date: Fri, 20 Jul 2012 11:16:20 -0700 (PDT)
Message-ID: <20120720.111620.1609537308761180.davem@davemloft.net>
References: <1342774928-29301-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab2GTSQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:16:21 -0400
In-Reply-To: <1342774928-29301-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Fri, 20 Jul 2012 12:02:08 +0300

> Is this patch still useful if routing cache is removed?

It is, since this function still gets used for rtnetlink route
queries.  So I'll apply this, thanks Julian!

Which reminds me that we don't have way to inspect the new TCP metrics
cache.  Would someone like to work on that?
