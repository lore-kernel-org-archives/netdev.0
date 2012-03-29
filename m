From: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Subject: =?utf-8?Q?=E7=AD=94=E5=A4=8D:_=E7=AD=94=E5=A4=8D:_=E7=AD=94=E5=A4=8D:_=5BP?=
	=?utf-8?Q?ATCH=5D_set_fake=5Frtable's_dst_to_N?=
	=?utf-8?Q?ULL_to_avoid_kernel_Oops.?=
Date: Thu, 29 Mar 2012 19:41:26 +0800
Message-ID: <007c01cd0da0$e0481040$a0d830c0$%huangpeng@huawei.com>
References: <002501cd0d74$317fd100$947f7300$%huangpeng@huawei.com>
 <1333002975.2325.82.camel@edumazet-glaptop>
 <002601cd0d76$c4987440$4dc95cc0$%huangpeng@huawei.com>
 <1333011120.2325.354.camel@edumazet-glaptop>
 <004501cd0d8f$c4e133b0$4ea39b10$%huangpeng@huawei.com>
 <1333020682.2325.517.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	zhoukang7@huawei.com, 'netdev' <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:57415 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab2C2LnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 07:43:20 -0400
In-reply-to: <1333020682.2325.517.camel@edumazet-glaptop>
Content-language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Check net/bridge/br_netfilter.c and commits e688a6048076 (net: introduce
> >DST_NOPEER dst flag )  4adf0af6818f3ea5 (bridge: send correct MTU value
> >in PMTU (revised))
> 
> This patch already included in kernel-3.3, but for our case, virtual tap device's delayed
> Deletion will also cause kernel oops even in kernel3.3.

>I was suggesting you take a look at the commit content ;)

>Then you can see the code in br_nf_local_in(), a bit cleaner than yours.

Yes, I will look into it, and trying to find out why this patch didn't work for our case.
Thanks for your advice:)
