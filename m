From: Kevin Hao <kexin.hao@windriver.com>
Subject: Re: [PATCH] net: remove LLTX in atl2 driver
Date: Fri, 26 Sep 2008 09:20:42 +0800
Message-ID: <1222392042.2682.40.camel@kevin>
References: <1222302922-13200-1-git-send-email-kexin.hao@windriver.com>
	 <48DBF4DD.8060908@redhat.com> <48DBFAB5.2010709@garzik.org>
	 <48DC11F5.20900@redhat.com>  <20080925185849.0df482e2@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36819 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbYIZBXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 21:23:36 -0400
In-Reply-To: <20080925185849.0df482e2@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-09-25 at 18:58 -0500, Jay Cliburn wrote:
> On Thu, 25 Sep 2008 18:34:29 -0400
> Chris Snook <csnook@redhat.com> wrote:
> 
> > 
> > I'm all in favor of removing legacy cruft.  I want to know a little
> > more about it so we can remove it from the atl1 code as well.
> > Ultimately most of this will be shared code.
> 
> Yes, LLTX can (and should) be removed from the atl1 code.  I had an
> exchange with Herbert Xu and David Miller on LKML a few weeks ago, and
> they gave me a few tips on how to do it, but I haven't yet had the
> time.  What takes an experienced netdev warrior about a half hour to
> implement unfortunately takes me days of after-dayjob time as I track
> through all the calls that that are affected and test the modified
> driver.
> 
> Now back to atl2...  I'd like to hear from Kevin also whether he tested
> the LLTX removal.  I'm building the driver with his patch as we speak,
> and I'll test it myself this weekend, but Kevin I'd still like to know
> if you tested the patch.

Yes, I have tested this driver on a Eee PC. It works well.

Thanks,
Kevin

> 
> Thanks,
> Jay
