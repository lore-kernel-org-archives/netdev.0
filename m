From: David Miller <davem@davemloft.net>
Subject: Re: v2: [PATCH 2/3] netdevice: Fix promiscuity and allmulti
 overflow
Date: Wed, 18 Jun 2008 01:49:42 -0700 (PDT)
Message-ID: <20080618.014942.208347071.davem@davemloft.net>
References: <48586A04.6040800@cn.fujitsu.com>
	<20080617.215402.169100957.davem@davemloft.net>
	<4858CADA.6020807@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40207
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751756AbYFRItl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 04:49:41 -0400
In-Reply-To: <4858CADA.6020807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 18 Jun 2008 10:44:10 +0200

> David Miller wrote:
> > From: Wang Chen <wangchen@cn.fujitsu.com>
> > Date: Wed, 18 Jun 2008 09:51:00 +0800
> >> Patrick McHardy said the following on 2008-6-17 20:59:
> >>> Assuming the caller does proper error handling, that printk is
> >>> not true.
> >> Yes.
> >> But currently, no caller handling this, and I think even if I make
> >> some callers to handle this, but there maybe some callers and their
> >> callers do not want to handle error condition.
> >> So I need a KERN_WARNING here.
> >> If some day, all of the caller handle the error properly, we can
> >> remove this printk.
> >>
> >> Here is v3:
> >
> > Patrick, ACK?
> 
> Yes, thanks.

Thanks, applied to net-next-2.6, I'll push to kernel.org after some
build sanity checks.

Since this is a bug fix we could put it into net-2.6, but I really
would like this to brew for a while in net-next-2.6 before doing
so.
