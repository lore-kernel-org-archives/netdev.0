From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] xfrm6 refcnt problem in bundle creation
Date: Wed, 21 Apr 2010 16:25:53 -0700 (PDT)
Message-ID: <20100421.162553.91324239.davem@davemloft.net>
References: <4BC73FB7.9090106@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38932
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754646Ab0DUXZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:25:49 -0400
In-Reply-To: <4BC73FB7.9090106@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Thu, 15 Apr 2010 18:32:55 +0200

> Subject: [PATCH] xfrm6: ensure to use the same dev when building a bundle
> 
> When building a bundle, we set dst.dev and rt6.rt6i_idev.
> We must ensure to set the same device for both fields.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

What we are doing now is definitely wrong and I think your
patch is the correct fix.

Applied to net-2.6, thanks!
