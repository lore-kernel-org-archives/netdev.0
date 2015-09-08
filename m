From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Remove VRF change to udp_sendmsg
Date: Tue, 08 Sep 2015 13:28:55 -0700 (PDT)
Message-ID: <20150908.132855.1931912800434042661.davem@davemloft.net>
References: <1441038580-44164-1-git-send-email-dsa@cumulusnetworks.com>
	<20150831.124410.99199729741650263.davem@davemloft.net>
	<55E4BCBE.4070900@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	tom@herbertland.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbbIHU25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 16:28:57 -0400
In-Reply-To: <55E4BCBE.4070900@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 31 Aug 2015 14:44:46 -0600

> If anything I should be going straight to fib_table_lookup in the VRF
> driver for this new lookup to get the source address. It knows the
> exact table that should be used and hence can avoid the rules walk +
> local table miss which happens using the ip_route_xxxxx functions as
> well as the rth lookup/create which is not needed here.

Definitely if this is the case you should do a direct fib_table_lookup().
