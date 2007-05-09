From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] core: Call net_tx_action only if work pending
Date: Tue, 08 May 2007 18:59:52 -0700 (PDT)
Message-ID: <20070508.185952.115910331.davem@davemloft.net>
References: <20070508073130.17546.91346.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967613AbXEIB7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 21:59:52 -0400
In-Reply-To: <20070508073130.17546.91346.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Tue, 08 May 2007 13:01:30 +0530

> Optimize call to net_tx_action only if work is pending.
> 
> Patch against net-2.6.22.git
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

I don't think downing a cpu is done so often as to justify this
microscopic optimization, do you?
