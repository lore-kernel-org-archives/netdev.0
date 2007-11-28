From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Wed, 28 Nov 2007 17:48:17 +0100
Message-ID: <20071128164817.GK3406@stusta.de>
References: <20071122343.446909000@suse.de> <200711261228.15155.rusty@rustcorp.com.au> <adahcj9sfan.fsf@cisco.com> <200711271549.37670.rusty@rustcorp.com.au> <1196202698.3415.119.camel@jcmlaptop> <20071127223743.GI24223@one.firstfloor.org> <20071127150022.61bdff7e@freepuppy.rosehill> <20071127230645.GB31491@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jon Masters <jonathan@jonmasters.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:39278 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755933AbXK1Qsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 11:48:30 -0500
Content-Disposition: inline
In-Reply-To: <20071127230645.GB31491@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2007 at 12:06:45AM +0100, Andi Kleen wrote:
> On Tue, Nov 27, 2007 at 03:00:22PM -0800, Stephen Hemminger wrote:
>...
> > of a modular ipv6 is flawed. 
> 
> Modules that cannot be unloaded are still useful. Standard case: Distributions
> like to offer an option to not use ipv6 because that is popular workaround
> for the common "DNS server eats AAAA queries and causes delays" issue.
> Forcing the user to rebuild the kernel for this wouldn't be practical.
> If ipv6 wasn't modular that would be hard to do.

It should be trivial doing it similar to the selinux=0 boot option.

> -Andi

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

