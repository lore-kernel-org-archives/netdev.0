From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] qed: Fix possible memory leak in
 qed_dcbnl_get_ieee_pfc()
Date: Sun, 14 Aug 2016 21:21:54 -0700 (PDT)
Message-ID: <20160814.212154.1839147931535183860.davem@davemloft.net>
References: <1470958194-25496-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	sudarsana.kalluru@qlogic.com, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbcHOEVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 00:21:55 -0400
In-Reply-To: <1470958194-25496-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 11 Aug 2016 23:29:54 +0000

> 'dcbx_info is malloced in qed_dcbnl_get_ieee_pfc() and should be freed
> before leaving from the error handling cases, otherwise it will cause
> memory leak.
> 
> Fixes: a1d8d8a51e83 ("qed: Add dcbnl support.")
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
