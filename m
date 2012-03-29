From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: =?UTF-8?Q?=E7=AD=94=E5=A4=8D=3A?=
 =?UTF-8?Q?_=E7=AD=94=E5=A4=8D=3A?= [PATCH] set fake_rtable's dst to NULL to
 avoid kernel Oops.
Date: Thu, 29 Mar 2012 13:31:22 +0200
Message-ID: <1333020682.2325.517.camel@edumazet-glaptop>
References: <002501cd0d74$317fd100$947f7300$%huangpeng@huawei.com>
	 <1333002975.2325.82.camel@edumazet-glaptop>
	 <002601cd0d76$c4987440$4dc95cc0$%huangpeng@huawei.com>
	 <1333011120.2325.354.camel@edumazet-glaptop>
	 <004501cd0d8f$c4e133b0$4ea39b10$%huangpeng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	zhoukang7@huawei.com, 'netdev' <netdev@vger.kernel.org>
To: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63932 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759078Ab2C2Lb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 07:31:27 -0400
In-Reply-To: <004501cd0d8f$c4e133b0$4ea39b10$%huangpeng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-29 at 17:38 +0800, Peter Huang (Peng) wrote:
> Thks for your mail.
> 
> >Check net/bridge/br_netfilter.c and commits e688a6048076 (net: introduce
> >DST_NOPEER dst flag )  4adf0af6818f3ea5 (bridge: send correct MTU value
> >in PMTU (revised))
> 
> This patch already included in kernel-3.3, but for our case, virtual tap device's delayed
> Deletion will also cause kernel oops even in kernel3.3.

I was suggesting you take a look at the commit content ;)

Then you can see the code in br_nf_local_in(), a bit cleaner than yours.
