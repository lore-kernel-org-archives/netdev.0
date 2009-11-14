From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: fix inet_bind_bucket_for_each
Date: Fri, 13 Nov 2009 20:49:43 -0800 (PST)
Message-ID: <20091113.204943.94495380.davem@davemloft.net>
References: <200911121707.26224.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com
To: lgrijincu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50268
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753753AbZKNEt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:49:27 -0500
In-Reply-To: <200911121707.26224.lgrijincu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Date: Thu, 12 Nov 2009 17:07:26 +0200

> The first "node" is supposed to be the cursor used in the for_each.
> 
> The second "node" is ment literally and should not be macro expanded:
> it's the name of the hlist_node field from the inet_bind_bucket.
> 
> This currently works because when inet_bind_bucket_for_each is called
> it's argument is still "node".
> 
> Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>

Applied.
