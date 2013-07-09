From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Tue, 9 Jul 2013 02:24:54 +0200
Message-ID: <20130709002454.GA20613@amd.pavel.ucw.cz>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
 <1373291269.4979.102.camel@edumazet-glaptop>
 <20130708220149.GA15766@electric-eye.fr.zoreil.com>
 <20130709000902.GB19366@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:49640 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400Ab3GIAY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 20:24:57 -0400
Content-Disposition: inline
In-Reply-To: <20130709000902.GB19366@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
> pavel@duo's password: 
> delme                                         100%   34MB 481.1KB/s   01:12    
> 
> Aha. I see abnormal ping times from duo to amd. (Cca 80msec range.)
> amd has e1000e card, and apparently its interrupt does not
> work. Fortunately it is shared with ahci so I can work around that
> one... and when I do, transfer gets even slower. Hmm?

I verified that copy is slow even from Elf to duo. Elf is old desktop,
and its ethernet card is working correctly, AFAICT.

Copy is even slower from Elf->duo, cca 66KB/sec. It is also slower
when I work around interrupt problems on amd, amd->duo is then cca
200KB/sec.

IOW yes amd's e1000e has a problem, but duo's realtek has even bigger
problem.

Thanks,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
