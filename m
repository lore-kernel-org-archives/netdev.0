From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] qed: potential overflow in qed_cxt_src_t2_alloc()
Date: Wed, 08 Jun 2016 00:33:36 -0700 (PDT)
Message-ID: <20160608.003336.1269899649820841663.davem@davemloft.net>
References: <20160607120416.GA2175@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbcFHHdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 03:33:43 -0400
In-Reply-To: <20160607120416.GA2175@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 7 Jun 2016 15:04:16 +0300

> In the current code "ent_per_page" could be more than "conn_num" making
> "conn_num" negative after the subtraction.  In the next iteration
> through the loop then the negative is treated as a very high positive
> meaning we don't put a limit on "ent_num".  It could lead to memory
> corruption.
> 
> Fixes: dbb799c39717 ('qed: Initialize hardware for new protocols')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
