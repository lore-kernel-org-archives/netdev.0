From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] alx: fix error handling in __alx_open
Date: Thu, 15 Sep 2016 20:15:56 -0400 (EDT)
Message-ID: <20160915.201556.927784623808264747.davem@davemloft.net>
References: <1473761217-18905-1-git-send-email-tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
To: tobias.regnery@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755521AbcIPAQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 20:16:57 -0400
In-Reply-To: <1473761217-18905-1-git-send-email-tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Tue, 13 Sep 2016 12:06:57 +0200

> In commit 9ee7b683ea63 we moved the enablement of msi interrupts earlier in
> alx_init_intr. If there is an error in alx_alloc_rings, __alx_open returns
> with an error but msi (or msi-x) interrupts stays enabled. Add a new error
> label to disable msi (or msi-x) interrupts.
> 
> Fixes: 9ee7b683ea63 ("alx: refactor msi enablement and disablement")
> Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>

Applied.
