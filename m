From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: increase receive packet quantum
Date: Tue, 04 Nov 2008 14:48:00 -0800 (PST)
Message-ID: <20081104.144800.158229098.davem@davemloft.net>
References: <20081103130303.29dd4e21@extreme>
	<20081103.172428.154364341.davem@davemloft.net>
	<20081103212521.15e12168@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754731AbYKDWsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 17:48:25 -0500
In-Reply-To: <20081103212521.15e12168@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 3 Nov 2008 21:25:21 -0800

> On Mon, 03 Nov 2008 17:24:28 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > I'll apply this to net-next-2.6, thanks Stephen.
> 
> Maybe you want it as part of the tbench regression recovery in 2.6.28?
> it seems mostly harmless.

Maybe...

I'd rather have it cook in net-next-2.6 for a while.

Taking up more than a jiffie in softirq context is
bordering on anti-social and could cause problems
especially for RT'ish stuff.

And I'm pretty sure that's why I made the change.
