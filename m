From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: AF_BUS socket address family
Date: Sun, 1 Jul 2012 15:16:59 +0100
Message-ID: <20120701151659.2be61475@pyramind.ukuu.org.uk>
References: <20120629234230.GA11480@kyllikki.org>
	<20120629.165023.1605284574408858612.davem@davemloft.net>
	<20120630141222.60df95a5@pyramind.ukuu.org.uk>
	<20120630.173346.670086962166528527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vincent.sanders@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120630.173346.670086962166528527.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The issue is that what to do when a receiver goes deaf is a policy
> issue.

Something all these protocols alredy recognize and have done for years.
The real issue for AF_BUS versus the current slow AF_UNIX approach is
that you really need to know *who* is blocked up.

That's no different to UDP multicast and needing to know how errored the
frame.

Alan
