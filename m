From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Wed, 21 May 2008 00:39:36 +0200
Message-ID: <200805210039.37248.rjw@sisk.pl>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <20080518150908.GA4606@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:46814 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765980AbYETWjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 18:39:20 -0400
In-Reply-To: <20080518150908.GA4606@yamamaya.is-a-geek.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, 18 of May 2008, Tobias Diedrich wrote:
> Tobias Diedrich wrote:
> > Note that so far this is only tested on my system with hibernate
> > using the 'shutdown' method.
> 
> Ok, I've run tests now:
> 
> First Windoze:
> Windoze, Standby (equiv. to Linux 'mem' state):  WOL borked, resumes fine
> Windoze, Hibernate: WOL borked, resumes fine
> 
> Linux, unpatched:
> Hibernate, shutdown method: Works with known caveats
> Hibernate, platform method: WOL borked,

That may be worth some investigation.  However, since that doesn't work on
Windows too, I suspect the platform is slightly broken.

> resumes fine 
> 
> Linux, patched:
> Hibernate, shutdown method: Works
> Hibernate, platform method: WOL borked, resumes fine
> Suspend ('standby' state):
>    WOL borked, USB borked after resume, kernel freeze
> Suspend ('mem' state, text console):
>    WOL borked, VGA stays dark, otherwise working

You can try s2ram to bring the VGA to life, I think
(http://suspend.sf.net/s2ram-support.html).

> Suspend ('mem' state, radeonfb):
>    WOL borked, VGA stays dark, userspace dead after resume (but pingable)
> 
> Summary: I suspect my BIOS sucks

That's possible ...

>         Version: ASUS M2N-SLI DELUXE ACPI BIOS Revision 0903
>         Release Date: 02/13/2007
> 
> 1 point for Linux, 0 points for Windows, Linux wins ;)

Thanks,
Rafael
