From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: add missing header dependencies
Date: Wed, 07 Sep 2016 17:41:30 -0700 (PDT)
Message-ID: <20160907.174130.1794006266279661720.davem@davemloft.net>
References: <1473246420-1035-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751741AbcIHAlb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 20:41:31 -0400
In-Reply-To: <1473246420-1035-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Wed,  7 Sep 2016 19:07:00 +0800

> We get 4 warnings when building kernel with W=1:
> drivers/net/ethernet/qlogic/qed/qed_selftest.c:6:5: warning: no previous prototype for 'qed_selftest_memory' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_selftest.c:19:5: warning: no previous prototype for 'qed_selftest_interrupt' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_selftest.c:32:5: warning: no previous prototype for 'qed_selftest_register' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_selftest.c:55:5: warning: no previous prototype for 'qed_selftest_clock' [-Wmissing-prototypes]
> 
> In fact, these functions are declared in qed_selftest.h, so this patch
> add missing header dependencies.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
