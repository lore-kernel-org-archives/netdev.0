From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 12:00:33 -0400 (EDT)
Message-ID: <20160419.120033.1902139695182044134.davem@davemloft.net>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
	<20160418.234137.26692086759328024.davem@davemloft.net>
	<5715E21C.1090108@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, eric.dumazet@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932858AbcDSQAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 12:00:37 -0400
In-Reply-To: <5715E21C.1090108@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 19 Apr 2016 09:45:32 +0200

> But we finally discover that some netlink API use the attribute '0'.

I explicitly did not use attribute zero, and instead made a new IFLA_*
attribute exactly to avoid compatability problems.

Every netlink attribute space that needs to deal with this padding issue
will need to add such a new attribute.

It is the only safe way to deal with this problem.
