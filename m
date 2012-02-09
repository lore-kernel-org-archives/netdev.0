From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netxen_nic: signedness bug in netxen_md_entry_err_chk()
Date: Wed, 08 Feb 2012 20:28:35 -0500 (EST)
Message-ID: <20120208.202835.161468483687895578.davem@davemloft.net>
References: <20120208092335.GC6554@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab2BIB2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 20:28:42 -0500
In-Reply-To: <20120208092335.GC6554@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 8 Feb 2012 12:23:36 +0300

> "esize" should be signed because it can be negative here.  For example,
> when we call it in netxen_parse_md_template(), it could be -1 from the
> return value of netxen_md_L2Cache().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
