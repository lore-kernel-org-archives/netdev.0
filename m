From: David Miller <davem@davemloft.net>
Subject: Re: [IP] TUNNEL: Fix to be built with user application.
Date: Tue, 23 Jan 2007 22:17:36 -0800 (PST)
Message-ID: <20070123.221736.95896013.davem@davemloft.net>
References: <11678173731728-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takamiya@po.ntts.co.jp
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47862
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030247AbXAXGRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:17:50 -0500
In-Reply-To: <11678173731728-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Wed,  3 Jan 2007 18:42:53 +0900

> include/linux/if_tunnel.h is broken for user application
> because it was changed to use __be32 which is required
> to include linux/types.h in advance but didn't.
> 
> (This issue is found when building MIPL2 daemon. We are not sure this
> is the last header to be fixed about __be32.)
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: TAKAMIYA Noriaki <takamiya@po.ntts.co.jp>

Patch applied, thank you.
