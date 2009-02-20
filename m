From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] gre: used time_before for comparing jiffies
Date: Fri, 20 Feb 2009 00:01:33 -0800 (PST)
Message-ID: <20090220.000133.175557384.davem@davemloft.net>
References: <499E2C54.9000409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58481
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752578AbZBTIBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:01:51 -0500
In-Reply-To: <499E2C54.9000409@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 20 Feb 2009 12:06:44 +0800

> The functions time_before is more robust for comparing
> jiffies against other values.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

There is some history of this in the networking code.

If you inspect carefully, the open-coded versions of
time comparisons in the networking have a larger window
of acceptance.

So actually, it is a regression fo use time_*() helpers
in these cases.

If these things have been like this for so long, it is
very likely there is a good reason :-)
