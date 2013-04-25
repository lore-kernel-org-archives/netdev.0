From: David Miller <davem@davemloft.net>
Subject: Re: [patch] NFC: llcp: two bugs in ->getname()
Date: Thu, 25 Apr 2013 01:49:11 -0400 (EDT)
Message-ID: <20130425.014911.738013858577867185.davem@davemloft.net>
References: <20130423062452.GD15893@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com, linville@tuxdriver.com,
	thierry.escande@linux.intel.com, levinsasha928@gmail.com,
	linux-wireless@vger.kernel.org, linux-nfc@ml01.01.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab3DYFtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:49:13 -0400
In-Reply-To: <20130423062452.GD15893@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 23 Apr 2013 09:24:52 +0300

> The sockaddr_nfc_llcp struct has as hole between ->sa_family and
> ->dev_idx so I've added a memset() to clear it and prevent an
> information leak.
> 
> Also the ->nfc_protocol element wasn't set so I've added that.
> 
> "uaddr->sa_family" and "llcp_addr->sa_family" are the same thing but
> it's less confusing to use llcp_addr consistently throughout.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
