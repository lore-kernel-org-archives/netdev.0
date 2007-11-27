From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 18:24:44 +0100
Message-ID: <20071127172444.GC3406@stusta.de>
References: <20071122343.446909000@suse.de> <200711271549.37670.rusty@rustcorp.com.au> <1196141742.9876.49.camel@trinity.ogc.int> <200711271002.22958.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:36083 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757515AbXK0RYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 12:24:55 -0500
Content-Disposition: inline
In-Reply-To: <200711271002.22958.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 10:02:22AM +0100, Andi Kleen wrote:
>...
> That is EXPORT_SYMBOL already. The trouble is just that it covers
> too much. My patchkit is trying to limit it again for a specific
> use case -- exporting an "internal" interface to another module.
> Or rather a set of modules. 
> 
> Standard example is TCP: TCP exports nearly everything and the
> single user is the TCP code in ipv6.ko. Instead those symbols should
> be limited to be only accessable to ipv6.ko. 
>...

Let's forget about external modules that are anyway irrelevant for 
upstream kernel development.

Do you have past examples where this would have brought advantages 
for the upstream kernel justifying all the work required for creating 
and maintaining these namespaces?

IOW, where modules were submitted for upstream inclusion and merging 
them was impossible or much harder only because they were developed 
aginst the wrong API?

> -ANdi

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

