From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] b44-ssb: Fix the SSB dependency hell
Date: Sat, 11 Aug 2007 16:30:02 +0200
Message-ID: <20070811143002.GE22213@stusta.de>
References: <200708110208.21624.mb@bu3sch.de> <1186793856.4862.16.camel@johannes.berg> <20070811014111.GB22213@stusta.de> <200708111136.46781.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:50214 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754292AbXHKOaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 10:30:15 -0400
Content-Disposition: inline
In-Reply-To: <200708111136.46781.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 11, 2007 at 11:36:46AM +0200, Michael Buesch wrote:
> 
> That's all a silly discussion, guys.
> I personally do _not_ care which way we do this.
> BUT: My users do care. There is currently no way telling them to first enable
> SSB, when they want to select b44 (for example).

The current status quo is that select handles it.

You want to send the users into menus to manually enable options.
That's worse for your users.

> Select _does_ introduce breakage. I did use select and I am pretty sure
> I got the dependencies right. And it _still_ broken on weird architectures.

Have you looked at how I proposed to handle the SSB dependencies?

If yes, why is this broken?

> So, I do not care how this is implemented. I do care however, that users
> do get an advice (at least) on what to do. And that's what my patch does.
> If someone has a better idea, please provide a patch.

I do care about your users.

And offering more options than required or manually sending users into 
other menus are bad thing for your users.

> Greetings Michael.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

