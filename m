From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH -next] net: hns: remove redundant dev_err call in
 hns_dsaf_get_cfg()
Date: Mon, 5 Sep 2016 14:02:53 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A6FA052@lhreml503-mbx>
References: <1471965063-2494-1-git-send-email-weiyj.lk@gmail.com>
 <20160823.171831.1833534604549127414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "Yankejian (Hackim Yim)" <yankejian@huawei.com>,
        xieqianqian <xieqianqian@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "weiyj.lk@gmail.com" <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:3369 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932413AbcIEODH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 10:03:07 -0400
In-Reply-To: <20160823.171831.1833534604549127414.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, August 24, 2016 1:19 AM
> To: weiyj.lk@gmail.com
> Cc: Zhuangyuzeng (Yisen); Salil Mehta; huangdaode; Yankejian (Hackim
> Yim); xieqianqian; weiyongjun (A); netdev@vger.kernel.org
> Subject: Re: [PATCH -next] net: hns: remove redundant dev_err call in
> hns_dsaf_get_cfg()
> 
> From: Wei Yongjun <weiyj.lk@gmail.com>
> Date: Tue, 23 Aug 2016 15:11:03 +0000
> 
> > From: Wei Yongjun <weiyongjun1@huawei.com>
> >
> > There is a error message within devm_ioremap_resource
> > already, so remove the dev_err call to avoid redundant
> > error message.
> >
> > Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Applied.
Hi David,
Forgive me for acting late on this but just realized that this patch will
Conflict with Doug Ledford's hns-roce's HNS driver. This might lead to
problems later during this merge window of 4.9. RoCE base driver has already
suffered because of such problem during earlier merge window. 

Can I request you to drop this patch for now? We shall submit this patch later
again either through hns-roce or directly to net-next.

Thanks in anticipation
Salil
