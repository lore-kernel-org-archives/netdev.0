From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qlcnic: use the correct ring in
 qlcnic_83xx_process_rcv_ring_diag()
Date: Wed, 29 Jun 2016 05:48:01 -0400 (EDT)
Message-ID: <20160629.054801.713412217544385924.davem@davemloft.net>
References: <20160627205029.GA22095@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, sony.chacko@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbcF2Jsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 05:48:33 -0400
In-Reply-To: <20160627205029.GA22095@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 27 Jun 2016 23:50:29 +0300

> There is a static checker warning here "warn: mask and shift to zero"
> and the code sets "ring" to zero every time.  From looking at how
> QLCNIC_FETCH_RING_ID() is used in qlcnic_83xx_process_rcv_ring() the
> qlcnic_83xx_hndl() should be removed.
> 
> Fixes: 4be41e92f7c6 ('qlcnic: 83xx data path routines')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
