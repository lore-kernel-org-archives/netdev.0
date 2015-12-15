From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] qlcnic: fix a timeout loop
Date: Tue, 15 Dec 2015 13:13:41 -0500 (EST)
Message-ID: <20151215.131341.175421419282676757.davem@davemloft.net>
References: <BLUPR11MB0114ED16EBE57CC01FD9797393EE0@BLUPR11MB0114.namprd11.prod.outlook.com>
	<20151215135616.GA18851@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, manish.chopra@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	rajesh.borundia@qlogic.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059AbbLOSNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 13:13:43 -0500
In-Reply-To: <20151215135616.GA18851@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 16:56:16 +0300

> The problem here is that at the end of the loop we test for if
> idc->vnic_wait_limit is zero, but since idc->vnic_wait_limit-- is a
> post-op, it actually ends up set to (u8)-1.  I have fixed this by
> moving the decrement inside the loop.
> 
> Fixes: 486a5bc77a4a ('qlcnic: Add support for 83xx suspend and resume.')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
