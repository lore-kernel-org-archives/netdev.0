From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mcs7830: Fix link state detection
Date: Thu, 11 Oct 2012 15:20:00 -0400 (EDT)
Message-ID: <20121011.152000.1869700919732028911.davem@davemloft.net>
References: <201210111233.28652.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@lisas.de, gregkh@linuxfoundation.org,
	lkml20120218@newton.leun.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201210111233.28652.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Thu, 11 Oct 2012 12:33:28 +0200

> The device had an undocumented "feature": it can provide a sequence of
> spurious link-down status data even if the link is up all the time.
> A sequence of 10 was seen so update the link state only after the device
> reports the same link state 20 times.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> Reported-by: Michael Leun <lkml20120218@newton.leun.net>
> Tested-by: Michael Leun <lkml20120218@newton.leun.net>

You've been given feedback on this patch, and also it doesn't apply
cleanly.  Perhaps it was corrupted by your email client.
