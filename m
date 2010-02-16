From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tunnels: fix netns vs proto registration ordering
Date: Tue, 16 Feb 2010 15:14:17 -0800 (PST)
Message-ID: <20100216.151417.32208925.davem@davemloft.net>
References: <20100216190504.GA4801@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933495Ab0BPXOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:14:02 -0500
In-Reply-To: <20100216190504.GA4801@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 16 Feb 2010 21:05:04 +0200

> Same stuff as in ip_gre patch: receive hook can be called before netns
> setup is done, oopsing in net_generic().
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6
