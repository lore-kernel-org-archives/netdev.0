From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: add setsockopt to disable slow start after idle
Date: Sun, 11 Apr 2010 13:18:50 -0700 (PDT)
Message-ID: <20100411.131850.226764423.davem@davemloft.net>
References: <4BC06A5F.6070804@gmail.com>
	<20100410.154709.201110995.davem@davemloft.net>
	<4BC218B6.8050703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cristiklein@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BC218B6.8050703@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cristian KLEIN <cristiklein@gmail.com>
Date: Sun, 11 Apr 2010 20:45:10 +0200

> Without this patch, an application which needs this behaviour
> (i.e. not to slow start after idle) is forced to implement its own
> UDP-based protocol with all the congestion control, retransmission
> etc. Undue congestion might still occur.

Ask your system administrator to set the existing sysctl, because it
is a physical network attribute whether this behavior is safe or not.

And if it is safe, it is safe for all applications, there is no reason
for one application to ask for it and others to not.  If it's legal,
it helps all applications without exception.

Your attempts to tie this to NAGLE is complete nonsense.

NAGLE changes acking behavior, whereas this feature controls in what
way we trust congestion control information we've probed for in the
past.
