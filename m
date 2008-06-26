From: Adrian Bunk <bunk@kernel.org>
Subject: Re: RFC: always enable MAC80211_RC_PID?
Date: Thu, 26 Jun 2008 21:10:06 +0300
Message-ID: <20080626181006.GB22827@cs181140183.pp.htv.fi>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi> <43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com> <1214298259.8967.260.camel@johannes.berg> <20080624124311.GC16021@cs181140183.pp.htv.fi> <1214502942.4432.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Mattias Nissler <mattias.nissler@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:56850 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418AbYFZSMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 14:12:17 -0400
Content-Disposition: inline
In-Reply-To: <1214502942.4432.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2008 at 07:55:42PM +0200, Mattias Nissler wrote:
> Just what I remember about the discussion that led to the ugly Makefile.
> 
> On Tue, 2008-06-24 at 15:43 +0300, Adrian Bunk wrote:
> > 
> > Can we get one of either:
> > - all selected mac80211 algorithms are built into the mac80211 module or
> 
> IIRC, this was originally voted against because this approach would
> increase kernel image size or module size unnecessarily.
>...

I don't see this point here.

People who _really_ need small kernels can still disable unneeded 
algorithms, and distribution kernels are anyway not usable for cases 
where a few kB more or less would matter.

> Mattias

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

