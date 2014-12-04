From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: less interrupt masking in NAPI
Date: Wed, 03 Dec 2014 18:51:45 -0800
Message-ID: <1417661505.22424.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141103.122538.387451917276174830.davem@davemloft.net>
	 <547EBC66.4040301@huawei.com>
	 <1417592482.5303.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <547ED728.2010703@huawei.com>
	 <1417607546.5303.133.camel@edumazet-glaptop2.roam.corp.google.com>
	 <547FC2A1.60105@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	willemb@google.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:58599 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbaLDCvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 21:51:54 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so15002812ieb.21
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 18:51:53 -0800 (PST)
In-Reply-To: <547FC2A1.60105@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-12-04 at 10:10 +0800, Yang Yingliang wrote:
> On 2014/12/3 19:52, Eric Dumazet wrote:
> > On Wed, 2014-12-03 at 17:26 +0800, Yang Yingliang wrote:
> > 
> >> Before this patch, when a large network flow arrives, some other processes
> >> response slowly or even don't response because the cpu is dealing with softirq.
> >>
> >> After this patch, under pressure, much more softirq is doing in ksoftirqd. The other
> >> processes be scheduled.
> >>
> >> My system has dual core.
> > 
> > Which NIC driver are you using ?
> > 
> The driver we developed ourself, it's not upstreamed.

Is it a NAPI driver ?

Quite frankly this patch is not a stable candidate, as it was a
performance improvement, with some regressions in a couple of drivers.
