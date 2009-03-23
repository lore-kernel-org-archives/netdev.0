From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netconsole: fix BUG during net device "upping"
Date: Sun, 22 Mar 2009 20:20:58 -0500
Message-ID: <1237771258.4231.134.camel@calx>
References: <49C61AAA.8050507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>, stable@kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>
To: Marcin Slusarz <marcin.slusarz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:38849 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753553AbZCWBcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2009 21:32:20 -0400
In-Reply-To: <49C61AAA.8050507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-03-22 at 12:02 +0100, Marcin Slusarz wrote:
> When ndo_open (eg skge_up) function printks something, netconsole decides
> it can use this device because it checks state only (netif_running) which is
> set before ndo_open. Check device flags too.

That's fairly unfortunate semantics for netif_running. But if Dave
agrees that it's reasonable for that to be set to true at this point in
time, then I guess we'll go with it.

-- 
http://selenic.com : development and support for Mercurial and Linux


