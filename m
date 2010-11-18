From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv6: Expose IFLA_PROTINFO timer values in
 msecs instead of jiffies
Date: Thu, 18 Nov 2010 11:05:23 -0800 (PST)
Message-ID: <20101118.110523.15238652.davem@davemloft.net>
References: <20101117114424.GA5838@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45785
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757546Ab0KRTE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 14:04:58 -0500
In-Reply-To: <20101117114424.GA5838@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Wed, 17 Nov 2010 06:44:24 -0500

> IFLA_PROTINFO exposes timer related per device settings in jiffies.
> Change it to expose these values in msecs like the sysctl interface
> does.
> 
> I did not find any users of IFLA_PROTINFO which rely on any of these
> values and even if there are, they are likely already broken because
> there is no way for them to reliably convert such a value to another
> time format.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.

Good to fix this now, thanks a lot Thomas.
