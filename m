From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh-eth: fix sleeping in atomic context
Date: Tue, 25 Sep 2012 13:08:31 -0400 (EDT)
Message-ID: <20120925.130831.369798738695859924.davem@davemloft.net>
References: <Pine.LNX.4.64.1209251143210.9446@axis700.grange>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, lethal@linux-sh.org,
	netdev@vger.kernel.org
To: g.liakhovetski@gmx.de
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1209251143210.9446@axis700.grange>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Date: Tue, 25 Sep 2012 12:38:59 +0200 (CEST)

> I'm not sure, whether this is the correct fix, i.e., whether this function 
> is guaranteed to be called on a resumed device, but at least this fixes 
> this specific issue in 3.6-rc7, but leaves another BUG open:

Someone added the runtime PM calls for a reason.

I cannot seriously consider your change until you are able to adequately
consider that aspect.
