From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: hns: mark symbols static where possible
Date: Wed, 26 Oct 2016 11:53:06 +0200
Message-ID: <21348245.KSjHuUMv5P@wuerfel>
References: <1477474968-13123-1-git-send-email-baoyou.xie@linaro.org> <CA+DQWkw5HkraYgMNtCJ+-VQKcxoVV+AzfnkjQEbRcNLnBcGkaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, yankejian@huawei.com,
        huangdaode@hisilicon.com, lisheng011@huawei.com, fabf@skynet.be,
        xieqianqian@huawei.com, lipeng321@huawei.com,
        Colin King <colin.king@canonical.com>, weiyongjun1@huawei.com,
        oulijun@huawei.com, vinod.koul@intel.com, andrew@lunn.ch,
        Philippe Reynes <tremyfr@gmail.com>, xypron.glpk@gmx.de,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        xie.baoyou@zte.com.cn, han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:53151 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752681AbcJZJzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 05:55:41 -0400
In-Reply-To: <CA+DQWkw5HkraYgMNtCJ+-VQKcxoVV+AzfnkjQEbRcNLnBcGkaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, October 26, 2016 5:48:32 PM CEST Baoyou Xie wrote:
> In fact, last month I sent a similar patch to fix the warnings, but this
> older patch is based on linux-next, not net git tree, so the patch didn't
> apply.
> 
> now, I rework the patch base on git://
> git.kernel.org/pub/scm/linux/kernel/git/davem/net.git.

I think I see the mistake that led to the confusion before: you should
base cleanups for network drivers on net-next.git, not net.git.
The correct URL is

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

and it is usually very close to linux-next, except for patches that
just got applied and have not made it into the latest linux-next.

Only if you find a serious bug, use net.git instead so the fix can
go into the mainline kernel.

	Arnd
