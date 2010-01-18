From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with 2.6.33-rc4-git2
Date: Mon, 18 Jan 2010 01:36:45 +0100
Message-ID: <201001180136.45823.rjw@sisk.pl>
References: <20100115091053.GA5477@mac.home> <201001152323.37718.rjw@sisk.pl> <20100117231932.GA5504@mac.home>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755200Ab0ARAgc@vger.kernel.org>
In-Reply-To: <20100117231932.GA5504@mac.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 18 January 2010, Tino Keitel wrote:
> On Fri, Jan 15, 2010 at 23:23:37 +0100, Rafael J. Wysocki wrote:
> > On Friday 15 January 2010, Stephen Hemminger wrote:
> 
> [...]
> 
> > > This has already been reported.
> > > 
> > > Rafael has been doing the generic PM stuff.
> > > Look for thread,
> > >  [Bug 14730] sky2 won't work after suspend/resume cycle
> > 
> > This has been fixed already and the bug appears to be different.
> 
> Yes, sounds different. The interface works after a resume. My issue is
> that the computer just won't resume at all using wake on LAN.
> 
> > 
> > No idea what it is at the moment.
> > 
> > Tino, please check if reverting commit
> > dc1a94ae1749d14c55f8b54e9d92bd89df82d51a helps, although the messages
> > indicate that the generic PCI-side does its job.
> 
> No luck with the commit reverted, WoL still doesn't work.

Well, this commit is the only PCI core change affecting WoL after 2.6.32 IIRC.

Rafael
