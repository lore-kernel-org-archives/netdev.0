From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix memory leak in sctp_datamsg_from_user() when
 copy from user space fails
Date: Sun, 25 Nov 2012 16:01:37 -0500 (EST)
Message-ID: <20121125.160137.2302577116716864395.davem@davemloft.net>
References: <1353590491-12166-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, vyasevich@gmail.com, sri@us.ibm.com,
	davej@redhat.com
To: tt.rantala@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390Ab2KYVBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 16:01:42 -0500
In-Reply-To: <1353590491-12166-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tommi Rantala <tt.rantala@gmail.com>
Date: Thu, 22 Nov 2012 15:21:31 +0200

> Trinity (the syscall fuzzer) discovered a memory leak in SCTP,
> reproducible e.g. with the sendto() syscall by passing invalid
> user space pointer in the second argument:
 ...
> As far as I can tell, the leak has been around since ~2003.
> 
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>

Looks good to me, Vlad please review.
