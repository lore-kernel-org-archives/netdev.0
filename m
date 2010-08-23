From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 15:23:30 -0700 (PDT)
Message-ID: <20100823.152330.184822588.davem@davemloft.net>
References: <AANLkTimWaULcbxkUh5aCsM+6fWPaTM8CkZZh2hB_cQ3-@mail.gmail.com>
	<20100823220129.GB2745@nuttenaction>
	<AANLkTinb_tjcz=AF1-2i7MK=Bgm7aEtozjb3Ds0swi8q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, acme@redhat.com, shemminger@vyatta.com
To: chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45113
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753912Ab0HWWXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 18:23:13 -0400
In-Reply-To: <AANLkTinb_tjcz=AF1-2i7MK=Bgm7aEtozjb3Ds0swi8q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <chris.snook@gmail.com>
Date: Mon, 23 Aug 2010 18:19:45 -0400

> Just because we've allowed stupid TCP sysctls in the past does not
> mean we should continue to do so now.  We recently made delayed ack a
> per-route tunable, so consistency would suggest we do the same here.
> Per-route tunables are more flexible, and as with the delayed ack
> patch, there are use cases where that granularity gives a clear
> advantage over a sysctl.  For example, you may want to disable quick
> ack on a high-MTU path and enable it on a low-MTU path.
> 
> If you need a hint for how to implement the per-route tunable, look
> for the delayed ack patch from early 2009.

I completely agree with Chris that this should be a per-route rather
than a global sysctl tunable.
