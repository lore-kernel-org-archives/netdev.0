From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Remove hoplimit initialization to -1
Date: Thu, 21 Apr 2011 17:25:01 -0700 (PDT)
Message-ID: <20110421.172501.245406861.davem@davemloft.net>
References: <4DAFF122.7010608@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.egerer@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56010
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754153Ab1DVAZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 20:25:34 -0400
In-Reply-To: <4DAFF122.7010608@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Egerer <thomas.egerer@secunet.com>
Date: Thu, 21 Apr 2011 10:56:02 +0200

> 
> The changes introduced with git-commit a02e4b7d missed to remove the
> hoplimit initialization. As a result, ipv6_get_mtu interprets the return
> value of dst_metric_raw (-1) as 255 and answers ping6 with this hoplimit.
> This patche removes the line such that ping6 is answered with the
> hoplimit value configured via sysctl.
> 
> Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>

Sorry for breaking this, patch applied.

Thanks!
