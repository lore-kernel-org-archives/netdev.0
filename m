From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Thu, 11 Jul 2013 02:24:03 +0200
Message-ID: <20130711002402.GA9889@amd.pavel.ucw.cz>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
 <1373291269.4979.102.camel@edumazet-glaptop>
 <20130710134104.GA4086@amd.pavel.ucw.cz>
 <20130710192929.GA28777@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:53677 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab3GKAYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 20:24:07 -0400
Content-Disposition: inline
In-Reply-To: <20130710192929.GA28777@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> > Actually, receiving is slow. Transmit is ok. "duo" is "bad" machine
> > with RTL card.
> 
> No hint from the hardware statistics (ethtool -S eth0) ?

Nothing suspicious _now_.

For some reason network started going expected speed. I replugged
cable few times, replugged power, tried different ethernet card, went
back to RTL, and worked around e1000e problem on the other
machine. Not sure what helped, but now transfers are in 10MB/sec
range. ... strange.

It seems ok now.

Thanks,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
