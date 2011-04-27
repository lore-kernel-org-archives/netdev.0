From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/7] SCTP updates for net-next-2.6
Date: Tue, 26 Apr 2011 18:47:57 -0700 (PDT)
Message-ID: <20110426.184757.226780553.davem@davemloft.net>
References: <20110426.001238.183056292.davem@davemloft.net>
	<20110426.145120.28826019.davem@davemloft.net>
	<4DB76A64.3020708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32878
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753933Ab1D0Bsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 21:48:30 -0400
In-Reply-To: <4DB76A64.3020708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 27 Apr 2011 08:59:16 +0800

> And I have a stupid question about the rule of backport.  Since those
> patchs have existed so long time, when I backport those patchs, I'd better
> fix the bug in the original patch, or create new patch to fix it? Also how
> about some thing need to improvement like the ->dst_saddr() method?

I think, since these are going in as patches, you should make any
corrections to those patches by fixing the patch.

Adding new patches is just going to keep the bug in there if people
try to bisect through these changes, and that's no good.

Thanks.
