From: David Miller <davem@davemloft.net>
Subject: Re: vlan/macvlan: fix NULL pointer dereferences in ethtool handlers
Date: Fri, 17 Apr 2009 15:59:43 -0700 (PDT)
Message-ID: <20090417.155943.174603790.davem@davemloft.net>
References: <49E8A8CC.8060305@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47049
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752815AbZDQW7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 18:59:51 -0400
In-Reply-To: <49E8A8CC.8060305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 17 Apr 2009 18:05:32 +0200

>     vlan/macvlan: fix NULL pointer dereferences in ethtool handlers
>     
>     Check whether the underlying device provides a set of ethtool ops before
>     checking for individual handlers to avoid NULL pointer dereferences.
>     
>     Reported-by: Art van Breemen <ard@telegraafnet.nl>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.

These things beg for helper functions in my opinion.
