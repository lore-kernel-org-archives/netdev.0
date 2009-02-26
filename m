From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: unloading the ipv6 module
Date: Thu, 26 Feb 2009 20:09:20 +0200
Message-ID: <20090226180920.GO28512@mea-ext.zmailer.org>
References: <49A69784.6070204@free.fr> <20090226.052411.77955912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel.lezcano@free.fr, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:42207 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbZBZSJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 13:09:25 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S3540791AbZBZSJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 20:09:20 +0200
Content-Disposition: inline
In-Reply-To: <20090226.052411.77955912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 05:24:11AM -0800, David Miller wrote:
> From: Daniel Lezcano <daniel.lezcano@free.fr>
> Date: Thu, 26 Feb 2009 14:22:12 +0100
> 
> > I saw in net/ipv6/Kconfig a comment saying
> > "IPv6 as module will cause a CRASH if you try to unload it".
> > 
> > If I refer to this comment, that means unloading of ipv6 is not
> > supported (which makes sense), will it be one day supported?
> 
> It's very unlikely to be supported any time soon.
> 
> Maybe "one day" as in 5 years from now at the earliest.

My guess is that somebody reasonably proficient coder with
a week of free time can get it to unload properly.

I did it once in 2.4 days, I recall..  Not completely, but mostly.

> It's just such an enormous set of problems to solve to make it work,
> and there are so many more urgent issues to work on.

Like refactoring the system to have IPv4 specific codes,
IPv6 specific codes, and common codes...   But DaveM has
probably other items in mind.

  /Matti Aarnio
