From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: make br_fdb_delete also check if the
 port matches
Date: Wed, 10 Jun 2015 21:58:32 -0700 (PDT)
Message-ID: <20150610.215832.1573210091736777397.davem@davemloft.net>
References: <1433846053-16390-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbbFKE6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 00:58:33 -0400
In-Reply-To: <1433846053-16390-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue,  9 Jun 2015 03:34:13 -0700

> Before this patch the user-specified bridge port was ignored when
> deleting an fdb entry and thus one could delete an entry that belonged
> to any port.
> Example (eth0 and eth1 are br0 ports):
> bridge fdb add 00:11:22:33:44:55 dev eth0 master
> bridge fdb del 00:11:22:33:44:55 dev eth1 master
> (succeeds)
> 
> after the patch:
> bridge fdb add 00:11:22:33:44:55 dev eth0 master
> bridge fdb del 00:11:22:33:44:55 dev eth1 master
> RTNETLINK answers: No such file or directory
> 
> Based on a patch by Wilson Kok.
> 
> Reported-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
