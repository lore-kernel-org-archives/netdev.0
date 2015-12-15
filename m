From: David Miller <davem@davemloft.net>
Subject: Re: [patch -mainline] qlge: fix a timeout loop in
 ql_change_rx_buffers()
Date: Tue, 15 Dec 2015 12:52:24 -0500 (EST)
Message-ID: <20151215.125224.1037822755732556120.davem@davemloft.net>
References: <20151215105236.GH20848@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@qlogic.com, sudarsana.kalluru@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965238AbbLORwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:52:25 -0500
In-Reply-To: <20151215105236.GH20848@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 13:52:36 +0300

> The problem here is that after the loop we test for "if (!i) " but
> because "i--" is a post-op we exit with i set to -1.  I have fixed this
> by changing it to a pre-op instead.  I had to change the starting value
> from 3 to 4 so that we still iterate 3 times.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
