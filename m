From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/8 2.6.32] CVE-2010-4251: packet backlog can get too
 large
Date: Sun, 13 Nov 2011 15:58:51 -0500 (EST)
Message-ID: <20111113.155851.2167389434844487922.davem@davemloft.net>
References: <20111113201336.GA1362@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, greg@kroah.com, netdev@vger.kernel.org,
	yi.zhu@intel.com, eric.dumazet@gmail.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab1KMU7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:59:04 -0500
In-Reply-To: <20111113201336.GA1362@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sun, 13 Nov 2011 23:13:36 +0300

> This patch series is to address CVE-2010-4251 for the 2.6.32 stable
> kernel.  Here is the CVE summary:
> 
>  "The socket implementation in net/core/sock.c in the Linux kernel
>   before 2.6.34 does not properly manage a backlog of received
>   packets, which allows remote attackers to cause a denial of service
>   (memory consumption) by sending a large amount of network traffic,
>   as demonstrated by netperf UDP tests."
> 
> [patch 1/8] introduces sk_add_backlog_limited()
> [patch 2-7/8] change each network protocol to use sk_add_backlog_limited()
> 	where appropriate.
> [patch 8/8] renames sk_add_backlog() to __sk_add_backlog() and
> 	sk_add_backlog_limited() to sk_add_backlog().
> 
> The patches mostly apply without changes.  The exception is:
> [patch 2/8] udp: use limited socket backlog
> Then the rename [patch 8/8] needed to be changed as well to match.

These changes are way too intrusive and potentially regression
inducing for -stable inclusion, especially a kernel that is in such
deep maintainence mode as 2.6.32 is.

Also, I tend to personally submit networking -stable patches, so please
do not bypass me in this manner and instead recommend such submissions
on the netdev list so I can evaluate the request.

Thanks.
