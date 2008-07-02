From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ipv4: fix sysctl documentation of time related
 values
Date: Tue, 01 Jul 2008 17:23:16 -0700 (PDT)
Message-ID: <20080701.172316.82436466.davem@davemloft.net>
References: <20080701153820.235faa72@extreme>
	<20080701153926.7b3fe1dd@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44862
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752987AbYGBAXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 20:23:16 -0400
In-Reply-To: <20080701153926.7b3fe1dd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 Jul 2008 15:39:26 -0700

> These sysctl values are time related and all use the same routine
> (proc_dointvec_jiffies) that internally converts from seconds to jiffies.
> The code is fine, the documentation is just wrong.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

As a doc fix, I've applied this to net-2.6, thanks!
