From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: Don't synchronize addresses while the vlan device is
 down
Date: Sat, 10 Nov 2007 21:51:52 -0800 (PST)
Message-ID: <20071110.215152.226849496.davem@davemloft.net>
References: <47334539.1010301@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49699
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752195AbXKKFvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:51:52 -0500
In-Reply-To: <47334539.1010301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 08 Nov 2007 18:19:53 +0100

> [VLAN]: Don't synchronize addresses while the vlan device is down
> 
> While the VLAN device is down, the unicast addresses are not configured
> on the underlying device, so we shouldn't attempt to sync them.
> 
> Noticed by Dmitry Butskoy <buc@odusz.so-cdu.ru>
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
