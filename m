From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-rc7-mm1
Date: Tue, 19 Sep 2006 13:36:06 -0700
Message-ID: <20060919133606.f0c92e66.akpm@osdl.org>
References: <20060919012848.4482666d.akpm@osdl.org>
	<200609192225.21801.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30359 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751278AbWISUgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 16:36:22 -0400
To: "Rafael J. Wysocki" <rjw@sisk.pl>
In-Reply-To: <200609192225.21801.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Sep 2006 22:25:21 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> > - It took maybe ten hours solid work to get this dogpile vaguely
> >   compiling and limping to a login prompt on x86, x86_64 and powerpc. 
> >   I guess it's worth briefly testing if you're keen.
> 
> It's not that bad, but unfortunately the networking doesn't work on my system
> (HPC nx6325 + SUSE 10.1 w/ updates, 64-bit).  Apparently, the interfaces don't
> get configured (both tg3 and bcm43xx are affected).

Is there anything interesting in the dmesg output?

Perhaps an `strace -f ifup' or whatever would tell us what's failing.
