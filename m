From: Adrian Bunk <bunk@kernel.org>
Subject: Re: sk98lin for 2.6.23-rc1
Date: Tue, 11 Sep 2007 13:54:56 +0200
Message-ID: <20070911115456.GM3563@stusta.de>
References: <20070905102230.10b0bdcf@oldman> <782111.42803.qm@web90413.mail.mud.yahoo.com> <46E2DF74.7040307@tmr.com> <20070908191132.GD3563@stusta.de> <46E35D8C.1070909@krose.org> <20070909111326.GF3563@stusta.de> <20070911100526.6aa5d463@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kyle Rose <krose@krose.org>, Bill Davidsen <davidsen@tmr.com>,
	James Corey <ploversegg@yahoo.com>,
	Rob Sims <lkml-z@robsims.com>, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:38782 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752189AbXIKLyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 07:54:49 -0400
Content-Disposition: inline
In-Reply-To: <20070911100526.6aa5d463@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 11, 2007 at 10:05:26AM +0200, Stephen Hemminger wrote:
> 
> There are several different problems in this thread:
> 1. The removal of old sk98lin driver caused some users to be forced to use
>     skge. These users have uncovered issues with the dual port fiber based versions
>     of the board.  
>     Short term: The sk98lin driver should be restored to previous state, 
>        and the PCI table should be used to limit the usage to only fiber systems.
>        If Adrian doesn't do it, I'll do it when I return from Germany.
>...

No problem with this, but since it was Jeff's patch it should better be 
him who reverts it (and he's anyway one step nearer to Linus).

But the underlying general problem still remains:

How can we get people to test and report bugs with the new drivers 
before removing the old driver?

That's a question especially for the people who now had problems after 
sk98lin was removed.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

