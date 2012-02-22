From: David Miller <davem@davemloft.net>
Subject: Re: [patch] hso: memsetting wrong data in hso_get_count()
Date: Wed, 22 Feb 2012 15:32:17 -0500 (EST)
Message-ID: <20120222.153217.1998630403338615530.davem@davemloft.net>
References: <20120222073024.GA7389@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab2BVUeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 15:34:25 -0500
In-Reply-To: <20120222073024.GA7389@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 22 Feb 2012 10:30:25 +0300

> The intent was to clear out the icount struct here, but we accidentally
> clear stack memory instead.  It probably will lead to a NULL dereference
> right away.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks a lot Dan.
