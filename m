From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH][2.6] e100_phy.c uses free'd .text after init
Date: Sun, 30 Nov 2003 09:35:52 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031129223552.GA24362@krispykreme>
References: <Pine.LNX.4.58.0311290033120.1674@montezuma.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0311290033120.1674@montezuma.fsmlabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Zwane,

> This was causing an oops when using mii-tool due to the .text being free'd
> after initialisation.

We stumbled across this a few weeks ago, Jeff's BK tree should have a
fix.

Anton
