From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 05 Jan 2009 22:07:42 -0800 (PST)
Message-ID: <20090105.220742.176919041.davem@davemloft.net>
References: <20090105.204934.65827705.davem@davemloft.net>
	<3f9a31f40901052114t68cac881md439bf24b602f269@mail.gmail.com>
	<20090106055144.GA11695@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jaswinderlinux@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dwmw2@infradead.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43194
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751167AbZAFGHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 01:07:40 -0500
In-Reply-To: <20090106055144.GA11695@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 6 Jan 2009 06:51:44 +0100

> We should avoid a central file and push this information
> out to the Kconfig files that are at the driver site.
> 
> Then we can postprocess autoconf.h to get the filenames etc.

I'll take this opportunity to once again promote my idea wherein build
information (and perhaps other bits like firmware info) for a driver
is encoded into the source of the driver itself, and the build system
just extracts that stuff into Makefiles and whatnot at build time. :-)

Couldn't resist.
