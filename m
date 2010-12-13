From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: add dev_close_many
Date: Mon, 13 Dec 2010 15:34:09 -0800
Message-ID: <20101213153409.47603d24@nehalam>
References: <1292249903-3865-1-git-send-email-opurdila@ixiacom.com>
	<201012131952.39648.opurdila@ixiacom.com>
	<20101213100447.50f77f3b@nehalam>
	<201012132254.24267.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"Lucian Adrian Grijincu" <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55332 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755909Ab0LMXeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 18:34:15 -0500
In-Reply-To: <201012132254.24267.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Dec 2010 22:54:24 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Monday 13 December 2010, 20:04:47
> 
> > I assume the need for dev_close_many is coming from a user space
> > application?
> > 
> > I expect that for this kind of special need,  you would be better off not
> > using the normal iproute utilities and instead have a custom device manager
> > that is doing netlink directly.
> > 
> > Rather than doing synchronous send request and wait for ack. The utility
> > could use a sender and collector thread.
> 
> Actually we need dev_close_many in order to speed up netdev_unregister_many 
> since in the netdev_unregister_many path there is still one more sync-rcu 
> operation which is not factorized.
> 
> I will prepare v2 to address David's comment and I will also be more explicit 
> in the commit message.

That makes sense.

-- 
