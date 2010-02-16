From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: fix netns vs proto registration ordering
Date: Tue, 16 Feb 2010 15:14:10 -0800 (PST)
Message-ID: <20100216.151410.176747254.davem@davemloft.net>
References: <20100216175744.GA4685@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933114Ab0BPXN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:13:58 -0500
In-Reply-To: <20100216175744.GA4685@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 16 Feb 2010 19:57:44 +0200

> GRE protocol receive hook can be called right after protocol addition is done.
> If netns stuff is not yet initialized, we're going to oops in
> net_generic().
> 
> This is remotely oopsable if ip_gre is compiled as module and packet
> comes at unfortunate moment of module loading.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6
