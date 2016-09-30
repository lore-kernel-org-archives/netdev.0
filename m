From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] net: hns: add missing function declaration
Date: Fri, 30 Sep 2016 16:32:24 +0200
Message-ID: <201609301632.24678.arnd@arndb.de>
References: <1475221315-18602-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, huangdaode@hisilicon.com,
        lisheng011@huawei.com, xieqianqian@huawei.com, fabf@skynet.be,
        oulijun@huawei.com, vinod.koul@intel.com, lipeng321@huawei.com,
        andrew@lunn.ch, tremyfr@gmail.com, chenny.xu@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        xie.baoyou@zte.com.cn, han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:55086 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932968AbcI3Odd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 10:33:33 -0400
In-Reply-To: <1475221315-18602-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 September 2016, Baoyou Xie wrote:
> We get 1 warning when building kernel with W=1:
> drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c:2784:5: warning: no previous prototype for 'hns_dsaf_roce_reset' [-Wmissing-prototypes]
> 
> In fact, this function is not declared in any file, but should be
> declared in a header file. thus can be recognized in other file.
> 
> so this patch adds the missing function declaration into
> drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

If you get to a case like this, please describe in the changelog how you determined that
the function is there intentionally, rather than something that should be removed?

I also see that you had sent the patch series for hns previously, and had included
a 'v2' version in the subject, but left out the version this time. Please always
use increasing version numbers when you send a new version of the series.

	Arnd
