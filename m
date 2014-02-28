From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net-next 1/2] vlan: don't allow vlan device to move
 between network namespaces
Date: Fri, 28 Feb 2014 22:07:14 +0900
Message-ID: <1393592834.1744.8.camel@localhost.localdomain>
References: <1393573839-32316-1-git-send-email-dingtianhong@huawei.com>
	 <1393573839-32316-2-git-send-email-dingtianhong@huawei.com>
	 <531044E1.6070005@lab.ntt.co.jp> <53104E4D.8060706@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>, kaber@trash.net,
	julia.lawall@lip6.fr, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:48412 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbaB1NHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 08:07:20 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa1so735299pad.13
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 05:07:19 -0800 (PST)
In-Reply-To: <53104E4D.8060706@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-28 at 16:52 +0800, Ding Tianhong wrote:
> On 2014/2/28 16:12, Toshiaki Makita wrote:
> > (2014/02/28 16:50), Ding Tianhong wrote:
> >> Now the vlan device could move to another network namespace, but
> >> the read dev is sill in the old network namespace, it is unsafe
> >> and the vlan device could not work well, so don't allow to do it.
> > 
> > Why is this a problem?
> > This looks like a useful feature to me.
> > 
> > Thanks,
> > Toshiaki Makita
> > 
> I think the vlan dev is a virtual device, if it does not with real dev together,
> I am not sure whether it is correct. Maybe I miss something, pls remind me.

It can be used to aggregate/distribute traffic from/to each namespace.
We can use vlan ids as identifiers for namespaces.
If there is a problem with this usage, I don't want to disable this
feature but want to fix the exact problem.

Thanks,
Toshiaki Makita
