From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net 00/19] net: hns: Misc. HNS Bug Fixes & Code
 Improvements
Date: Fri, 31 Mar 2017 09:58:24 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A8E7600@lhreml503-mbx>
References: <20170330153106.14344-1-salil.mehta@huawei.com>
 <20170330.200317.1176664200594872180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:17076 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750903AbdCaJ6s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 05:58:48 -0400
In-Reply-To: <20170330.200317.1176664200594872180.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, March 31, 2017 4:03 AM
> To: Salil Mehta
> Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net 00/19] net: hns: Misc. HNS Bug Fixes & Code
> Improvements
> 
> From: Salil Mehta <salil.mehta@huawei.com>
> Date: Thu, 30 Mar 2017 16:30:47 +0100
> 
> > This patch set introduces various HNS bug fixes, optimizations and
> code
> > improvements.
> 
> There is no way you should do such an expensive calculation for every
> single transmit packet as you are doing in your select_queue() routine.
> 
> That's really crazy.
> 
> Just use the networking stack's queue selection scheme, or suggest
> ways to improve it.  Don't do private hashing like this in your
> driver, please!
Hi David,
I got your point. I will drop this patch from this patch-set for now.

Thanks
Salil 
