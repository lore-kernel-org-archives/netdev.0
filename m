From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: e1000e hardware CRC stripping breaks bridging
Date: Tue, 12 Feb 2008 12:23:33 -0500
Message-ID: <20080212172333.GE856@gospo.usersys.redhat.com>
References: <47B19EDE.5020802@gentoo.org> <1202824670.26114.20.camel@gentoo-johan.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, Auke Kok <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org
To: Johan Andersson <johan.andersson@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759846AbYBLRXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 12:23:45 -0500
Content-Disposition: inline
In-Reply-To: <1202824670.26114.20.camel@gentoo-johan.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2008 at 02:57:50PM +0100, Johan Andersson wrote:
> Here is the bug report:
> http://bugzilla.kernel.org/show_bug.cgi?id=9940
> 
> /Johan
> 
> On Tue, 2008-02-12 at 13:27 +0000, Daniel Drake wrote:
> > Hi,
> > 
> > Johan Andersson reported on the Gentoo bugzilla that the hardware CRC 
> > stripping enabled by e1000e breaks bridging because sometimes the CRC is 
> > not stripped:
> > https://bugs.gentoo.org/show_bug.cgi?id=209235
> > 
> > Apparently "upstream" are aware but I couldn't find any mails or bug 
> > reports on this topic.
> > 
> > What's the current status of this issue? Perhaps we should disable 
> > hardware CRC stripping for 2.6.24.x/2.6.25 until this gets fixed?
> > 
> > Thanks,
> > Daniel


This patch, just needs to get reverted:

commit 140a74802894e9db57e5cd77ccff77e590ece5f3
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Thu Oct 25 13:57:58 2007 -0700

    e1000e: Re-enable SECRC - crc stripping

