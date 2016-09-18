From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: hns: add function declarations in hns_dsaf_mac.h
Date: Sun, 18 Sep 2016 22:37:29 +0200
Message-ID: <2457639.urVBpTjXKo@wuerfel>
References: <1474189896-20417-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, yankejian@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:61289 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759501AbcIRUiT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 16:38:19 -0400
In-Reply-To: <1474189896-20417-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, September 18, 2016 5:11:36 PM CEST Baoyou Xie wrote:
> We get 2 warnings when building kernel with W=1:
> drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c:246:6: warning: no previous prototype for 'hns_dsaf_srst_chns' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c:276:6: warning: no previous prototype for 'hns_dsaf_roce_srst' [-Wmissing-prototypes]
> 
> In fact, these two functions are not declared in any file, but should
> be declared in a header file, thus can be recognized in other file.
> 
> So this patch adds the declarations into
> drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> 

Why can't these be declared static?

	Arnd
