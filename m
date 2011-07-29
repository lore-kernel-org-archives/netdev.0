From: Petar Bogdanovic <petar@smokva.net>
Subject: Re: [PATCH] drivers/net/tun.c: test for CAP_NET_ADMIN before
 attaching
Date: Fri, 29 Jul 2011 16:42:12 +0200
Message-ID: <20110729144212.GB25695@pintail.smokva.net>
References: <20110729142808.GA25695@pintail.smokva.net>
 <20110729.073623.544936174715744280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from morrison.andev.ch ([78.47.142.202]:65347 "EHLO
	morrison.andev.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab1G2OmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 10:42:15 -0400
Received: from pintail.smokva.net (84-73-26-94.dclient.hispeed.ch [84.73.26.94])
	by morrison.andev.ch (Postfix) with ESMTP id 23A735DA90
	for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 16:42:22 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20110729.073623.544936174715744280.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2011 at 07:36:23AM -0700, David Miller wrote:
> From: Petar Bogdanovic <petar@smokva.net>
> Date: Fri, 29 Jul 2011 16:28:08 +0200
> 
> > The following change will test for CAP_NET_ADMIN before attaching, even
> > if both tun->owner and tun->group equal -1.  The latter scenario can be
> > reproduced with ip(8) from iproute2, when using `ip tuntap' without the
> > `user' and `group' option.
> 
> Please read linux/Documentation/SubmittingPatches, for example you
> need to provide a proper "Signed-off-by: " tag at the end of your
> commit message.

Ok, thanks.
