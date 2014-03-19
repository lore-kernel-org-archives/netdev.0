From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] micrel: fix masking off LED bits
Date: Wed, 19 Mar 2014 17:42:05 -0400 (EDT)
Message-ID: <20140319.174205.1425627653050633421.davem@davemloft.net>
References: <201403190258.16812.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	ben.dooks@codethink.co.uk
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201403190258.16812.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 19 Mar 2014 02:58:16 +0300

> Commit 20d8435a1cff (phy: micrel: add of configuration for LED mode) made the
> obvious mistake when masking off  the LED mode bits: forgot to do a logical NOT
> to the mask with which it ANDs the register value, so that unrelated bits are
> cleared instead.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied to net-next, thanks.
