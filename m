From: David Miller <davem@davemloft.net>
Subject: Re: [patch -mainline] amd-xgbe: fix a couple timeout loops
Date: Tue, 15 Dec 2015 12:51:42 -0500 (EST)
Message-ID: <20151215.125142.35117005882837154.davem@davemloft.net>
References: <20151215101229.GF20848@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028AbbLORvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:51:44 -0500
In-Reply-To: <20151215101229.GF20848@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 13:12:29 +0300

> At the end of the loop we test "if (!count)" but because "count--" is
> a post-op then the loop will end with count set to -1.  I have fixed
> this by changing it to --count.
> 
> Fixes: c5aa9e3b8156 ('amd-xgbe: Initial AMD 10GbE platform driver')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
