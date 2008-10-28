From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] oops in net_rx_action on 64-bit powerpc
Date: Tue, 28 Oct 2008 15:51:28 -0700 (PDT)
Message-ID: <20081028.155128.144329082.davem@davemloft.net>
References: <4902B1D8.8070800@nortel.com>
	<20081025.001703.261277154.davem@davemloft.net>
	<49065942.4040300@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, romieu@fr.zoreil.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751165AbYJ1Wvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:51:50 -0400
In-Reply-To: <49065942.4040300@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Mon, 27 Oct 2008 18:13:54 -0600

> [PATCH] fix amd8111e rx return code
> 
> The amd8111e rx poll routine currently mishandles the case when we process
> exactly the number of packets specified in the budget.
> 
> This patch is basically as suggested by David Miller.
> 
> Signed-off-by: Chris Friesen <cfriesen@nortel.com>

I had to apply this by hand because your email client heavily
corrupted the patch.

Thanks.

