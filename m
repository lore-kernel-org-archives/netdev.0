From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] tcp: select(writefds) don't hang up when a peer close connection
Date: Mon, 30 Aug 2010 10:08:53 +0900 (JST)
Message-ID: <20100830085152.5237.A69D9226@jp.fujitsu.com>
References: <1282824448.2263.3.camel@achroite.uk.solarflarecom.com> <20100826.122104.115920380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100826.122104.115920380.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 26 Aug 2010 13:07:28 +0100
> 
> > By the way, I was able to reproduce this bug in RHEL 3 (kernel based on
> > 2.4.21) so it seems to have been around for a while.
> 
> It's existed since September 1998:
> 
> commit 6275af56642b5b9ed9ef15bf5d9718661c5fe79d
> Author: freitag <freitag>
> Date:   Sat Sep 26 06:20:25 1998 +0000
> 
>     Some small fixes.
>     
>     - Remove second check for sk->err in poll as discussed with Linus.
>     - Don't signal writability when the local end has been shut down.
>     - Comment fixes.

because (almostly) nobody were using this feature? ;)
