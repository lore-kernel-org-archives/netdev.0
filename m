From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: 2.6 patch] net/netlink/: possible cleanups
Date: Tue, 18 Apr 2006 16:19:46 +0200
Message-ID: <20060418141946.GC11582@stusta.de>
References: <20060413162710.GE4162@stusta.de> <20060413.132603.94193712.davem@davemloft.net> <20060414103202.GF4162@stusta.de> <20060414105610.GA18149@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:23813 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S932159AbWDROTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 10:19:47 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060414105610.GA18149@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2006 at 02:56:12PM +0400, Evgeniy Polyakov wrote:
>...
> Although it is always statically built systems, it is still very
> convenient way of netlink usage for others (future modular systems).

I do understand Dave's "new API, users are expected soon" point.

OTOH, we also have to always check whether users are expected soon (and 
recheck whether there are really users after some time) since every 
single export makes the kernel larger for nearly everyone.

> 	Evgeniy Polyakov

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

