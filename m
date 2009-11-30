From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 PATCH] net: Move && and || to end of
 previous line
Date: Mon, 30 Nov 2009 09:28:37 -0800
Message-ID: <20091130092837.4998f961@nehalam>
References: <1259001504.16503.79.camel@Joe-Laptop.home>
	<20091123.104130.117837098.davem@davemloft.net>
	<1259528449.29779.194.camel@Joe-Laptop.home>
	<20091129.165557.84377714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47386 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015AbZK3R2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 12:28:47 -0500
In-Reply-To: <20091129.165557.84377714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Nov 2009 16:55:57 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Joe Perches <joe@perches.com>
> Date: Sun, 29 Nov 2009 13:00:49 -0800
> 
> > Not including net/atm/
> > 
> > Compiled tested x86 allyesconfig only
> > Added a > 80 column line or two, which I ignored.
> > Existing checkpatch plaints willfully, cheerfully ignored.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Applied, thanks a lot Joe.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Rather than playing with the dangling operator format which seems to be a coding
style that only David cares about. Why not go through and fix the really ugly old
drivers that need it. For a good horror experience, go look at the floppy driver.
